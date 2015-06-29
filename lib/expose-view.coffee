{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

ExposeTabView = require './expose-tab-view'
{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  items: []

  @content: ->
    @div class: 'expose-view animate', tabindex: -1, =>
      @div class: 'expose-top', =>
        @a outlet: 'exposeSettings', class: 'icon-gear'
        @a class: 'icon-x'
      @div outlet: 'tabList', class: 'tab-bar'

  constructor: (serializedState) ->
    super

  initialize: ->
    @disposables = new CompositeDisposable
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

    @disposables.add atom.commands.add @element,
      'core:confirm': -> exposeHide()
      'core:cancel': -> exposeHide()
      'expose:activate-1': => @activateTab(1)
      'expose:activate-2': => @activateTab(2)
      'expose:activate-3': => @activateTab(3)
      'expose:activate-4': => @activateTab(4)
      'expose:activate-5': => @activateTab(5)
      'expose:activate-6': => @activateTab(6)
      'expose:activate-7': => @activateTab(7)
      'expose:activate-8': => @activateTab(8)
      'expose:activate-9': => @activateTab(9)

  didChangeVisible: (visible) ->
    if visible then @focus() else atom.workspace.getActivePane().activate()

    # Animation does not trigger when class is set immediately
    setTimeout (=> @element.classList.toggle('visible', visible)), 0

  getGroupColor: (n) ->
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#9b59b6']
    colors[n % colors.length]

  update: ->
    @tabList.empty()
    @items = []

    for pane, i in atom.workspace.getPanes()
      color = @getGroupColor(i)
      for item in pane.getItems()
        exposeTabView = new ExposeTabView(item, color)
        @items.push exposeTabView
        @tabList.append exposeTabView

  activateTab: (n = 1) ->
    n = 1 if n < 1
    n = @items.length if n > 9 or n > @items.length
    @items[n-1]?.activateTab()
