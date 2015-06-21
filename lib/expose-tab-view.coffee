{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  @content: (item) ->
    @div click: 'activateTab', class: 'tab-container', =>
      @div class: 'tab', =>
        @div class: 'title', item.getTitle()
        @div click: 'closeTab', class: 'close-icon'
      @div class: 'tab-body', =>
        @p '<PREVIEW>'

  initialize: (@item) ->


  activateTab: (event) ->
    event.stopPropagation()
    atom.workspace.paneForItem(@item).activateItem(@item)
    exposeHide()

  closeTab: (event) ->
    event.stopPropagation()
    atom.workspace.paneForItem(@item).destroyItem(@item)
    @destroy()

  destroy: ->
    @remove()
    @disposables?.dispose()
