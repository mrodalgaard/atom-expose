{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

ExposeTabView = require './expose-tab-view'
{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  @content: ->
    @div class: 'expose-view animate', =>
      @div class: 'expose-top', =>
        @a outlet: 'exposeSettings', class: 'icon-gear'
        @a class: 'icon-x'
      @div outlet: 'tabList', class: 'tab-bar'

  constructor: (serializedState) ->
    super
    @disposables = new CompositeDisposable

  initialize: ->
    @handleEvents()

  serialize: ->

  destroy: ->
    @remove()
    @disposables?.dispose()

  handleEvents: ->
    @exposeSettings.on 'click', ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'settings-view:view-installed-packages')

    # This event gets propagated from most element clicks on top
    @on 'click', (event) ->
      event.stopPropagation()
      exposeHide()

  didChangeVisible: (visible) ->
    setTimeout (=> @element.classList.toggle('visible', visible)), 0

  update: ->
    @tabList.empty()
    for item in atom.workspace.getPaneItems()
      @tabList.append new ExposeTabView(item)
