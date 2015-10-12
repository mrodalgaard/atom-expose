{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'
Sortable = require 'sortablejs'

ExposeTabView = require './expose-tab-view'

module.exports =
class ExposeView extends View
  tabs: []

  @content: ->
    @div class: 'expose-view', tabindex: -1, =>
      @div class: 'expose-top', =>
        @a outlet: 'exposeSettings', class: 'icon-gear'
        @a class: 'icon-x close-icon'
      @div outlet: 'tabList', class: 'tab-list'

  initialize: ->
    @disposables = new CompositeDisposable
    @handleEvents()
    @handleDrag()

  destroy: ->
    @remove()
    @disposables?.dispose()

  handleEvents: ->
    @exposeSettings.on 'click', ->
      atom.workspace.open 'atom://config/packages/expose'

    # This event gets propagated from most element clicks on top
    @on 'click', (event) =>
      event.stopPropagation()
      @exposeHide()

    @disposables.add atom.config.observe 'expose.useAnimations', (value) =>
      @element.classList.toggle('animate', value)

    @disposables.add atom.commands.add @element,
      'core:confirm': => @exposeHide()
      'core:cancel': => @exposeHide()
      'core:move-right': => @nextTab()
      'core:move-left': => @nextTab(-1)
      'expose:close': => @exposeHide()
      'expose:activate-1': => @activateTab(1)
      'expose:activate-2': => @activateTab(2)
      'expose:activate-3': => @activateTab(3)
      'expose:activate-4': => @activateTab(4)
      'expose:activate-5': => @activateTab(5)
      'expose:activate-6': => @activateTab(6)
      'expose:activate-7': => @activateTab(7)
      'expose:activate-8': => @activateTab(8)
      'expose:activate-9': => @activateTab(9)

    @disposables.add atom.workspace.onDidAddPaneItem => @update()
    @disposables.add atom.workspace.onDidDestroyPaneItem => @update()

  handleDrag: ->
    Sortable.create(
      @tabList.context
      ghostClass: 'ghost'
      onEnd: (evt) => @moveTab(evt.oldIndex, evt.newIndex)
    )

  moveTab: (from, to) ->
    return unless fromItem = @tabs[from]?.item
    return unless toItem = @tabs[to]?.item

    fromPane = atom.workspace.paneForItem(fromItem)
    toPane = atom.workspace.paneForItem(toItem)

    toPaneIndex = 0
    for item, i in toPane.getItems()
      toPaneIndex = i if item is toItem

    fromPane.moveItemToPane(fromItem, toPane, toPaneIndex)
    @update(true)

  didChangeVisible: (@visible) ->
    if visible
      @update()
      @focus()
    else
      atom.workspace.getActivePane().activate()

    # Animation does not trigger when class is set immediately
    setTimeout (=> @element.classList.toggle('visible', visible)), 0

  getGroupColor: (n) ->
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#9b59b6']
    colors[n % colors.length]

  update: (force) ->
    return unless @visible or force
    @removeTabs()

    for pane, i in atom.workspace.getPanes()
      color = @getGroupColor(i)
      for item in pane.getItems()
        exposeTabView = new ExposeTabView(item, color)
        @tabs.push exposeTabView
        @tabList.append exposeTabView
    @focus()

  removeTabs: ->
    @tabList.empty()
    for tab in @tabs
      tab.destroy()
    @tabs = []

  activateTab: (n = 1) ->
    n = 1 if n < 1
    n = @tabs.length if n > 9 or n > @tabs.length
    @tabs[n-1]?.activateTab()
    @exposeHide()

  nextTab: (n = 1) ->
    for tabView, i in @tabs
      if tabView.isActiveTab()
        n = @tabs.length - 1 if i+n < 0
        nextTabView.activateTab() if nextTabView = @tabs[(i+n)%@tabs.length]
        return @focus()

  exposeHide: ->
    for panel in atom.workspace.getModalPanels()
      panel.hide() if panel.className is 'expose-panel'
