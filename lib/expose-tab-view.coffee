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
    @populateTabBody()

  populateTabBody: ->
    return if @drawImage()
    return if @drawCanvas()
    @drawFallback()

  drawFallback: ->
    element = document.createElement 'i'
    if @item.constructor.name is 'TextEditor'
      element.className = 'icon-file-code'
    else
      element.className = 'icon-file-text'
    @tabBody.append(element)

  drawImage: ->
    return unless @item.constructor.name is 'ImageEditor'

    element = document.createElement 'img'
    element.src = @item.file.path
    @tabBody.append(element)

  drawCanvas: ->
    return unless @item.constructor.name is 'TextEditor'

    minimapCanvas = @getMinimapCanvas()

    # Check if canvas was found and is not empty
    return unless minimapCanvas
    return if minimapCanvas.toDataURL() is document.createElement('canvas').toDataURL()

    element = document.createElement 'canvas'
    element.getContext('2d').drawImage(minimapCanvas, 0, 0)
    @tabBody.append(element)

  getMinimapCanvas: ->
    loadedPackages = atom.packages.loadedPackages
    return unless loadedPackages.minimap

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
