path = require 'path'

ExposeTabView = require '../lib/expose-tab-view'

describe "ExposeTabView", ->
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    atom.project.setPaths [path.join(__dirname, 'fixtures')]

  describe "populateTabBody()", ->
    it "can populate empty item", ->
      exposeTabView = new ExposeTabView
      expect(Object.getOwnPropertyNames(exposeTabView.item)).toHaveLength 0
      expect(exposeTabView.find('.title').text()).toBe 'untitled'
      expect(exposeTabView.tabBody.find('a')).toHaveLength 1
      expect(exposeTabView.tabBody.find('a').attr('class')).toContain 'text'
      expect(exposeTabView.pending).toBe false

    it "populates normal text editor", ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.item).toBeDefined()
        expect(exposeTabView.title).toBe 'sample1.txt'
        expect(exposeTabView.tabBody.find('a')).toHaveLength 1
        expect(exposeTabView.tabBody.find('a').attr('class')).toContain 'code'

    it "populates image editor", ->
      waitsForPromise ->
        atom.packages.activatePackage 'image-view'
        atom.workspace.open '../../screenshots/preview.png'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.item).toBeDefined()
        expect(exposeTabView.title).toBe 'preview.png'
        expect(exposeTabView.tabBody.find('img')).toHaveLength 1
        expect(exposeTabView.tabBody.find('img').attr('src')).toBeDefined()

    it "populates settings view", ->
      waitsForPromise ->
        jasmine.attachToDOM(workspaceElement)
        atom.packages.activatePackage 'settings-view'
      runs ->
        atom.commands.dispatch workspaceElement, 'settings-view:open'
        waitsFor ->
          atom.workspace.getActivePaneItem()
        runs ->
          item = atom.workspace.getActivePaneItem()
          exposeTabView = new ExposeTabView(item)

          expect(exposeTabView.title).toBe 'Settings'
          expect(exposeTabView.tabBody.find('a')).toHaveLength 1
          expect(exposeTabView.tabBody.find('a').attr('class')).toContain 'tools'

    it "populates archive view", ->
      waitsForPromise ->
        atom.packages.activatePackage 'archive-view'
        atom.workspace.open 'archive.zip'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.title).toBe 'archive.zip'
        expect(exposeTabView.tabBody.find('a')).toHaveLength 1
        expect(exposeTabView.tabBody.find('a').attr('class')).toContain 'zip'

    it "populates markdown view", ->
      waitsForPromise ->
        atom.packages.activatePackage 'markdown-preview'
        atom.workspace.open '../../README.md'
      runs ->
        item = null
        atom.commands.dispatch workspaceElement, 'markdown-preview:toggle'

        waitsFor ->
          item = atom.workspace.getPaneItems()[1]
        runs ->
          exposeTabView = new ExposeTabView(item)
          expect(exposeTabView.title).toBe 'README.md Preview'
          expect(exposeTabView.tabBody.find('a')).toHaveLength 1
          expect(exposeTabView.tabBody.find('a').attr('class')).toContain 'markdown'

    it "populates text editor with minimap activated", ->
      waitsForPromise ->
        atom.packages.activatePackage 'minimap'
        jasmine.attachToDOM(workspaceElement)
        atom.workspace.open 'sample1.txt'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        waitsFor ->
          exposeTabView.tabBody.html()
        runs ->
          expect(exposeTabView.item).toBeDefined()
          expect(exposeTabView.title).toBe 'sample1.txt'
          expect(exposeTabView.tabBody.find('atom-text-editor-minimap')).toHaveLength 1

    it "marks pending tabs", ->
      waitsForPromise ->
        atom.workspace.open('sample1.txt', pending: true)
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(exposeTabView.title).toBe 'sample1.txt'
        expect(exposeTabView.pending).toBe true

  describe "closeTab()", ->
    it "destroys selected tab item", ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
      runs ->
        item = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(item)

        expect(atom.workspace.getTextEditors()).toHaveLength 1
        expect(exposeTabView.title).toBe 'sample1.txt'
        expect(exposeTabView.disposables.disposed).toBeFalsy()

        exposeTabView.closeTab()

        expect(atom.workspace.getTextEditors()).toHaveLength 0
        expect(exposeTabView.disposables.disposed).toBeTruthy()

  describe "activateTab()", ->
    it "activates selected tab item", ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
        atom.workspace.open 'sample2.txt'
      runs ->
        items = atom.workspace.getPaneItems()
        activeItem = atom.workspace.getActivePaneItem()
        exposeTabView = new ExposeTabView(items[0])

        expect(items).toHaveLength 2
        expect(activeItem.getTitle()).toBe 'sample2.txt'
        expect(exposeTabView.title).toBe 'sample1.txt'

        exposeTabView.activateTab()
        activeItem = atom.workspace.getActivePaneItem()

        expect(activeItem.getTitle()).toBe 'sample1.txt'
