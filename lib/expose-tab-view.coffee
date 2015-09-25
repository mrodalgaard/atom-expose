{View, $$} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

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
    return if @drawMinimap()
    @drawFallback()

  drawFallback: ->
    objectClass = @item.constructor.name
    iconClass = 'icon-' + @item.getIconName() if @item.getIconName
    @tabBody.html $$ ->
      @a class: iconClass or switch objectClass
        when 'TextEditor' then 'icon-file-code'
        when 'ArchiveEditor' then 'icon-file-zip'
        else 'icon-file-text'

  drawImage: ->
    return unless @item.constructor.name is 'ImageEditor'
    filePath = @item.file.path
    @tabBody.html $$ ->
      @img src: filePath

  drawMinimap: ->
    return unless @item.constructor.name is 'TextEditor'
    return unless atom.packages.loadedPackages.minimap

    atom.packages.serviceHub.consume 'minimap', '1.0.0', (minimapAPI) =>
      if minimapAPI.standAloneMinimapForEditor?
        minimap = minimapAPI.standAloneMinimapForEditor(@item)
        minimapElement = atom.views.getView(minimap)
        minimapElement.style.cssText = '''
          width: 134px;
          height: 90px;
          right: initial;
          transform: translate3d(32px, 22px, 0px) scale3d(1.5, 1.5, 1)
        '''
        @tabBody.html minimapElement
      else
        @tabBody.html $$ ->
          @a class: 'icon-sync'

  activateTab: (event) ->
    pane = atom.workspace.paneForItem(@item)
    pane.activate()
    pane.activateItem(@item)

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
