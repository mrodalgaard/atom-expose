{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

ExposeTabView = require './expose-tab-view'
{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  @content: ->
    @div class: 'expose-view', =>
      @div class: 'expose-top', =>
        @a outlet: 'exposeSettings', class: 'icon-gear'
        @a outlet: 'exposeHide', class: 'icon-x'
      @div outlet: 'tabList', class: 'tab-bar'

  constructor: (serializedState) ->
    super
    @disposables = new CompositeDisposable

    @exposeHide.on 'click', exposeHide
    @exposeSettings.on 'click', ->
      editor = atom.workspace.getActiveTextEditor()
      atom.commands.dispatch(atom.views.getView(editor), 'settings-view:view-installed-packages')
      exposeHide()

  serialize: ->

  destroy: ->
    @remove()
    @disposables?.dispose()

  update: ->
    @tabList.empty()
    for pane in atom.workspace.getPanes()
      for item in pane.getItems()
        @tabList.append new ExposeTabView(item)
