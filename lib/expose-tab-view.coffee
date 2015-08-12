{View, $$} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  title: 'newfile'

  @content: (title, color) ->
    @div click: 'activateTab', class: 'tab', =>
      @div class: 'tab-header', =>
        @div class: 'title icon-file-text', 'data-name': title, title
        @div click: 'closeTab', class: 'close-icon icon-x'
      @div outlet: 'tabBody', class: 'tab-body', style: "border-color: #{color}"

  constructor: (@item = {}, @color = '#000') ->
    @title = item.getTitle?() if item?
    super(@title, @color)

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
        when 'ResultsPaneView' then 'icon-search'
        when 'ArchiveEditor' then 'icon-file-zip'
        when 'MarkdownPreviewView' then 'icon-markdown'
        when 'ShowTodoView' then 'icon-checklist'
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

  # XXX: Experiment with drawing DOM objects into canvas and scale
  # to not depend on minimap and be able to draw every type of view
  # Mozilla: https://goo.gl/0QPvF7
  # rasterizeHTML: https://goo.gl/HIKjyN
  drawCanvasExperiment: ->
    canvas = document.createElement 'canvas'
    ctx = canvas.getContext '2d'

    element = atom.views.getView(@item)
    htmlString = element.querySelectorAll('atom-text-editor /deep/ .editor--private')[0].innerHTML

    data =  """
            <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">
              <foreignObject width="100%" height="100%">
                <div xmlns="http://www.w3.org/1999/xhtml" style="font-size:40px">
                  #{htmlString}
                </div>
              </foreignObject>
            </svg>
            """

    DOMURL = window.URL || window.webkitURL || window

    img = new Image
    svg = new Blob([data], {type: 'image/svg+xml;charset=utf-8'})
    url = DOMURL.createObjectURL(svg)

    img.onload = ->
      console.log 'SVG image loaded'
      ctx.drawImage(img, 0, 0)
      DOMURL.revokeObjectURL(url)

    img.src = url
    @tabBody.html canvas

  activateTab: (event) ->
    atom.workspace.paneForItem(@item).activateItem(@item)

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
