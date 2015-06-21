path = require 'path'

ExposeTabView = require '../lib/expose-tab-view'

describe "ExposeTabView", ->
  beforeEach ->
    atom.project.setPaths [path.join(__dirname, 'fixtures')]

  describe "populateTabBody()", ->
    it "can populate empty item", ->
      exposeTabView = new ExposeTabView
      expect(Object.getOwnPropertyNames(exposeTabView.item).length).toBe 0
      expect(exposeTabView.find('.title').text()).toBe 'newfile'
      expect(exposeTabView.tabBody.find('a').length).toBe 1

    it "populates normal text editor", ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.item).toBeDefined()
        expect(exposeTabView.title).toBe 'sample1.txt'
        expect(exposeTabView.tabBody.find('a').length).toBe 1

    it "populates image editor", ->
      waitsForPromise ->
        atom.packages.activatePackage 'image-view'
        atom.workspace.open '../../screenshots/preview.png'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.item).toBeDefined()
        expect(exposeTabView.title).toBe 'preview.png'
        expect(exposeTabView.tabBody.find('img').length).toBe 1

    it "populates text editor with minimap activated", ->
      waitsForPromise ->
        atom.packages.activatePackage 'minimap'
        workspaceElement = atom.views.getView(atom.workspace)
        jasmine.attachToDOM(workspaceElement)
        atom.workspace.open 'sample1.txt'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.item).toBeDefined()
        expect(exposeTabView.title).toBe 'sample1.txt'
        expect(exposeTabView.tabBody.find('canvas').length).toBe 1

  describe "closeTab()", ->
    it "destroys selected tab item", ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(atom.workspace.getTextEditors().length).toBe 1
        expect(exposeTabView.title).toBe 'sample1.txt'
        expect(exposeTabView.destroyed).toBeFalsy()

        exposeTabView.closeTab()

        expect(atom.workspace.getTextEditors().length).toBe 0
        expect(exposeTabView.destroyed).toBeTruthy()

  describe "activateTab()", ->
    it "activates selected tab item", ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
        atom.workspace.open 'sample2.txt'
      runs ->
        items = atom.workspace.getPaneItems()
        activeItem = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(items[0])

        expect(items.length).toBe 2
        expect(activeItem.getTitle()).toBe 'sample2.txt'
        expect(exposeTabView.title).toBe 'sample1.txt'

        exposeTabView.activateTab()
        activeItem = atom.workspace.getActivePaneItem()

        expect(activeItem.getTitle()).toBe 'sample1.txt'
