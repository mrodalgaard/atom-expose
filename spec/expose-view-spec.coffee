path = require 'path'

ExposeView = require '../lib/expose-view'

describe "ExposeView", ->
  exposeView = null

  beforeEach ->
    exposeView = new ExposeView
    atom.project.setPaths [path.join(__dirname, 'fixtures')]

  describe "update()", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
        atom.workspace.open 'sample2.txt'

    it "populates list of open tabs", ->
      expect(exposeView.tabList.children()).toHaveLength 0
      expect(exposeView.tabs).toHaveLength 0
      exposeView.update()
      expect(exposeView.tabList.children()).toHaveLength 2
      expect(exposeView.tabs).toHaveLength 2

    it "assign colors to different panes", ->
      atom.workspace.getActivePane().splitRight(copyActiveItem: true)
      exposeView.update()
      expect(atom.workspace.getPanes()).toHaveLength 2
      expect(exposeView.tabs).toHaveLength 3

      color1 = exposeView.getGroupColor(0)
      color2 = exposeView.getGroupColor(1)
      expect(exposeView.tabs[1].color).toEqual color1
      expect(exposeView.tabs[2].color).toEqual color2
      expect(color1).not.toEqual color2

  describe "activateTab(n)", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
        atom.workspace.open 'sample2.txt'
        atom.workspace.open 'sample3.txt'

    it "activates given tab", ->
      exposeView.update()
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample3.txt'
      exposeView.activateTab(2)
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample2.txt'
      exposeView.activateTab(1)
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample1.txt'

    it "handles out of range input", ->
      exposeView.update()
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample3.txt'
      exposeView.activateTab(2)
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample2.txt'
      exposeView.activateTab(9)
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample3.txt'
      exposeView.activateTab(0)
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample1.txt'
      exposeView.activateTab()
      expect(atom.workspace.getActivePaneItem().getTitle()).toEqual 'sample1.txt'

  describe "moveTab(from, to)", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
        atom.workspace.open 'sample2.txt'
        atom.workspace.open 'sample3.txt'

    it "can move tabs", ->
      exposeView.update()
      expect(exposeView.tabs).toHaveLength 3
      expect(exposeView.tabs[0].title).toEqual 'sample1.txt'
      expect(exposeView.tabs[2].title).toEqual 'sample3.txt'
      exposeView.moveTab(2, 0)
      expect(exposeView.tabs[0].title).toEqual 'sample3.txt'
      expect(exposeView.tabs[2].title).toEqual 'sample2.txt'

    it "can move tabs between panes", ->
      atom.workspace.getActivePane().splitRight(copyActiveItem: true)
      exposeView.update()

      color1 = exposeView.getGroupColor(0)
      color2 = exposeView.getGroupColor(1)
      expect(color1).not.toEqual color2
      expect(exposeView.tabs).toHaveLength 4
      expect(exposeView.tabs[2].title).toEqual 'sample3.txt'
      expect(exposeView.tabs[3].title).toEqual 'sample3.txt'
      expect(exposeView.tabs[3].color).toEqual color2

      exposeView.moveTab(0, 3)
      expect(exposeView.tabs[2].title).toEqual 'sample1.txt'
      expect(exposeView.tabs[2].color).toEqual color2
      expect(exposeView.tabs[0].title).toEqual 'sample2.txt'
      expect(exposeView.tabs[0].color).toEqual color1

      exposeView.moveTab(3, 0)
      expect(exposeView.tabs[0].title).toEqual 'sample3.txt'
      expect(exposeView.tabs[0].color).toEqual color1

    it "handles invalid input", ->
      exposeView.update()
      exposeView.moveTab()
      expect(exposeView.tabs[0].title).toEqual 'sample1.txt'
      exposeView.moveTab(9, 9)
      expect(exposeView.tabs[2].title).toEqual 'sample3.txt'
