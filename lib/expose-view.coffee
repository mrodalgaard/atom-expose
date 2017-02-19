{CompositeDisposable, TextBuffer} = require 'atom'
{View, TextEditorView} = require 'atom-space-pen-views'
{filter} = require 'fuzzaldrin'
Sortable = require 'sortablejs'

ExposeTabView = require './expose-tab-view'

module.exports =
class ExposeView extends View
  tabs: []

  @content: (searchBuffer) ->
    searchTextEditor = atom.workspace.buildTextEditor(
      mini: true
      tabLength: 2
      softTabs: true
      softWrapped: false
      buffer: searchBuffer
      placeholderText: 'Search tabs'
    )

    @div class: 'expose-view', tabindex: -1, =>
      @div class: 'expose-top input-block', =>
        @div class: 'input-block-item input-block-item--flex', =>
          @subview 'searchView', new TextEditorView(editor: searchTextEditor)
        @div class: 'input-block-item', =>
          @div class: 'btn-group', =>
            @button outlet: 'exposeSettings', class: 'btn icon-gear'
            @button class: 'btn icon-x'

      @div outlet: 'tabList', class: 'tab-list'

  constructor: () ->
    super @searchBuffer = new TextBuffer

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

    @searchView.on 'click', (event) ->
      event.stopPropagation()

    @searchView.getModel().onDidStopChanging =>
      @update() if @didIgnoreFirstChange
      @didIgnoreFirstChange = true

    # This event gets propagated from most element clicks on top
    @on 'click', (event) =>
      event.stopPropagation()
      @exposeHide()

    @disposables.add atom.config.observe 'expose.useAnimations', (value) =>
      @element.classList.toggle('animate', value)

    @disposables.add atom.commands.add @element,
      'core:confirm': => @handleConfirm()
      'core:cancel': => @exposeHide()
      'core:move-right': => @nextTab()
      'core:move-left': => @nextTab(-1)
      'expose:close': => @exposeHide()
      'expose:activate-1': => @handleNumberKey(1)
      'expose:activate-2': => @handleNumberKey(2)
      'expose:activate-3': => @handleNumberKey(3)
      'expose:activate-4': => @handleNumberKey(4)
      'expose:activate-5': => @handleNumberKey(5)
      'expose:activate-6': => @handleNumberKey(6)
      'expose:activate-7': => @handleNumberKey(7)
      'expose:activate-8': => @handleNumberKey(8)
      'expose:activate-9': => @handleNumberKey(9)

    @on 'keydown', (event) => @handleKeyEvent(event)

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
    if @visible
      @searchBuffer.setText('')
      @update()
      @focus()
    else
      atom.workspace.getActivePane().activate()

    # Animation does not trigger when class is set immediately
    setTimeout (=> @element.classList.toggle('visible', @visible)), 0

  getGroupColor: (n) ->
    colors = ['#3498db', '#e74c3c', '#2ecc71', '#9b59b6']
    colors[n % colors.length]

  update: (force) ->
    return unless @visible or force
    @removeTabs()

    @tabs = []
    for pane, i in atom.workspace.getPanes()
      color = @getGroupColor(i)
      for item in pane.getItems()
        @tabs.push new ExposeTabView(item, color)

    @renderTabs(@tabs = @filterTabs(@tabs))

  filterTabs: (tabs) ->
    text = @searchBuffer.getText()
    return tabs if text is ''
    filter(tabs, text, key: 'title')

  renderTabs: (tabs) ->
    for tab in tabs
      @tabList.append tab

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

  handleConfirm: ->
    if @isSearching() then @activateTab() else @exposeHide()

  handleNumberKey: (number) ->
    if @isSearching()
      @searchView.getModel().insertText(number.toString())
    else
      @activateTab(number)

  handleKeyEvent: (event) ->
    ignoredKeys = ['shift', 'control', 'alt', 'meta']
    @searchView.focus() if ignoredKeys.indexOf(event.key.toLowerCase()) is -1

  nextTab: (n = 1) ->
    for tabView, i in @tabs
      if tabView.isActiveTab()
        n = @tabs.length - 1 if i+n < 0
        nextTabView.activateTab() if nextTabView = @tabs[(i+n)%@tabs.length]
        return @focus()

  exposeHide: ->
    @didIgnoreFirstChange = false
    for tab in @tabs
      tab.destroy()
    for panel in atom.workspace.getModalPanels()
      panel.hide() if panel.className is 'expose-panel'

  isSearching: -> @searchView.hasClass('is-focused')
