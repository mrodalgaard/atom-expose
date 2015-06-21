path = require 'path'

ExposeView = require '../lib/expose-view'

describe "ExposeView", ->
  exposeView = null

  beforeEach ->
    pathname = 'dummyData'
    exposeView = new ExposeView
    atom.project.setPaths [path.join(__dirname, 'fixtures')]

  describe "update()", ->
    beforeEach ->
      waitsForPromise ->
        atom.workspace.open 'sample1.txt'
        atom.workspace.open 'sample2.txt'

    it "populates list of open tabs", ->
      expect(exposeView.tabList.children().length).toBe 0
      exposeView.update()
      expect(exposeView.tabList.children().length).toBe 2
