{View, $$} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  title: 'newfile'

  @content: (title) ->
    @div click: 'activateTab', class: 'tab-container', =>
      @div class: 'tab', =>
        @div class: 'title icon-file-text', 'data-name': title, title
        @div click: 'closeTab', class: 'close-icon'
      @div outlet: 'tabBody', class: 'tab-body'

  constructor: (@item = {}) ->
    @title = item.getTitle?() if item?
    super @title

  initialize: ->
    @handleEvents()
    @populateTabBody()

  populateTabBody: ->
    return if @drawImage()
    return if @drawCanvas()
    @drawFallback()

  drawFallback: ->
    objectClass = @item.constructor.name
    @tabBody.html $$ ->
      @a class: switch objectClass
        when 'TextEditor' then 'icon-file-code'
        when 'SettingsView' then 'icon-tools'
        else 'icon-file-text'

  drawImage: ->
    return unless @item.constructor.name is 'ImageEditor'
    filePath = @item.file.path
    @tabBody.html $$ ->
      @img src: filePath

  drawCanvas: ->
    return unless @item.constructor.name is 'TextEditor'

    return unless minimapCanvas = @getMinimapCanvas()

    # Draw sync link if canvas is empty
    if minimapCanvas.toDataURL() is document.createElement('canvas').toDataURL()
      @tabBody.html $$ ->
        @a class: 'icon-sync'
    else
      canvas = document.createElement 'canvas'
      canvas.getContext('2d').drawImage(minimapCanvas, 0, 0)
      @tabBody.html canvas

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

  activateTab: (event) ->
    event?.stopPropagation()
    atom.workspace.paneForItem(@item).activateItem(@item)
    exposeHide()

  closeTab: (event) ->
    event?.stopPropagation()
    atom.workspace.paneForItem(@item).destroyItem(@item)
    @destroy()

  handleEvents: ->
    @on 'click', '.icon-sync', (event) =>
      event.stopPropagation()
      event.target.className += ' animate'
      atom.workspace.paneForItem(@item).activateItem(@item)
      setTimeout (=> @populateTabBody()), 1000

  destroy: ->
    @destroyed = true
    @remove()
    @disposables?.dispose()
