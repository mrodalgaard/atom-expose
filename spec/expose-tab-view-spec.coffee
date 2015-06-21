path = require 'path'

ExposeTabView = require '../lib/expose-tab-view'

describe "ExposeTabView", ->
  exposeTabView = null

  beforeEach ->
    exposeTabView = null
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
        expect(exposeTabView.find('.title').text()).toBe 'sample1.txt'
        expect(exposeTabView.tabBody.find('a').length).toBe 1

    it "populates image editor", ->
      waitsForPromise ->
        atom.packages.activatePackage 'image-view'
        atom.workspace.open '../../screenshots/preview.png'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.item).toBeDefined()
        expect(exposeTabView.find('.title').text()).toBe 'preview.png'
        expect(exposeTabView.tabBody.find('img').length).toBe 1
