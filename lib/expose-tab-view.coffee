{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  @content: (item) ->
    @div click: 'activateTab', class: 'tab-container', =>
      @div class: 'tab', =>
        @div class: 'title icon-file-text', 'data-name': item.getTitle(), item.getTitle()
        @div click: 'closeTab', class: 'close-icon'
      @div outlet: 'tabBody', class: 'tab-body'

  initialize: (@item) ->

    # FIXME: Is being called double sometimes

    if item.constructor.name is 'ImageEditor'
      @drawImage()
    else
      @drawCanvas()

  drawCanvas: ->
    minimapCanvas = @getMinimapCanvas()

    # TODO: Create fallback if minimap is not loaded or has no content
    return if !minimapCanvas

    element = document.createElement 'canvas'
    element.width = 190
    element.height = 130
    element.getContext('2d').drawImage(minimapCanvas, 0, 0)

    @tabBody.append(element)

  drawImage: ->
    element = document.createElement 'img'
    element.width = 190
    element.height = 120
    element.src = @item.file.path

    @tabBody.append(element)

  getMinimapCanvas: ->
    loadedPackages = atom.packages.loadedPackages
    return if !loadedPackages.minimap

    # HACK: Steal canvas from minimap
    # Fails if item does not have minimap object
    try
      minimapModule = loadedPackages['minimap'].mainModule
      minimap = minimapModule.minimapForEditor(@item)
      minimapView = atom.views.getView(minimap)
      minimapView.querySelectorAll('atom-text-editor-minimap /deep/ canvas')[0]
    catch error
      return

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
