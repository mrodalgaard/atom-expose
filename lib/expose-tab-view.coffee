{View, $$} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class ExposeView extends View
  @content: (title, color) ->
    @div click: 'activateTab', class: 'expose-tab', =>
      @div class: 'tab-header', =>
        @div class: 'title icon-file-text', 'data-name': title, title
        @div click: 'closeTab', class: 'close-icon icon-x'
      @div outlet: 'tabBody', class: 'tab-body', style: "border-color: #{color}"

  constructor: (@item = {}, @color = '#000') ->
    super(@title = @getItemTitle(item), @color)

  initialize: ->
    @disposables = new CompositeDisposable
    @handleEvents()
    @populateTabBody()

  handleEvents: ->
    @on 'click', '.icon-sync', @refreshTab

    @disposables.add atom.commands.add @element,
      'expose:close-tab': (e) => @closeTab(e)

    atom.workspace.observeActivePaneItem @toggleActive

  destroy: ->
    @destroyed = true
    @remove()
    @disposables?.dispose()

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

        # Override minimap scroll, remove controls and set custom style
        minimapElement.controls?.remove()
        minimapElement.style.cssText = '''
          width: 190px;
          height: 130px;
          left: 10px;
          pointer-events: none;
          // transform: scale3d(1.5, 1.5, 1) translate(-20px, 15px);
        '''

        minimap.setCharWidth(2)
        minimap.setCharHeight(4)
        minimap.setInterline(2)

        @tabBody.html minimapElement
      else
        @tabBody.html $$ ->
          @a class: 'icon-sync'

  refreshTab: (event) =>
    event.stopPropagation()
    event.target.className += ' animate'
    atom.workspace.paneForItem(@item).activateItem(@item)
    setTimeout (=> @populateTabBody()), 1000

  activateTab: ->
    pane = atom.workspace.paneForItem(@item)
    pane.activate()
    pane.activateItem(@item)

  toggleActive: (item) =>
    @toggleClass('active', item is @item)

  isActiveTab: ->
    atom.workspace.getActivePaneItem() is @item

  closeTab: (event) ->
    event?.stopPropagation()
    atom.workspace.paneForItem(@item).destroyItem(@item)
    @destroy()

  getItemTitle: (item) ->
    return 'untitled' unless title = item?.getTitle()

    for paneItem in atom.workspace.getPaneItems() when paneItem isnt item
      if paneItem.getTitle() is title and item.getLongTitle?
        title = item.getLongTitle()
    title
