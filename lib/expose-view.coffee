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

  getGroupColor: (n) ->
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#9b59b6']
    colors[n % colors.length]

  update: ->
    @tabList.empty()
    for pane, i in atom.workspace.getPanes()
      color = @getGroupColor(i)
      for item in pane.getItems()
        @tabList.append new ExposeTabView(item, color)
