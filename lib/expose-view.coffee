{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

ExposeTabView = require './expose-tab-view'
{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  @content: ->
    @div class: 'expose-view', =>
      @div class: 'expose-top', =>
        @a outlet: 'exposeHide', class: 'icon-x expose-close'
      @div outlet: 'tabList', class: 'tab-bar'

  constructor: (serializedState) ->
    super
    @disposables = new CompositeDisposable

    @update()

    @exposeHide.on 'click', exposeHide

  serialize: ->

  destroy: ->
    this.remove()

  getElement: ->
    this

  update: ->
    @tabList.empty()
    for pane in atom.workspace.getPanes()
      for item in pane.getItems()
        exposeTabView = new ExposeTabView(item)
        @tabList.append(exposeTabView)
