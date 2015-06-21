{CompositeDisposable} = require 'atom'

ExposeView = require './expose-view'

module.exports = Expose =
  exposeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @exposeView = new ExposeView(state.exposeViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @exposeView, visible: false, className: 'expose-panel')

    # Make modal fill workspace
    @modalPanel.getItem().element.parentElement.style.left = '0'
    @modalPanel.getItem().element.parentElement.style.margin = 'auto'
    @modalPanel.getItem().element.parentElement.style.width = '100%'
    @modalPanel.getItem().element.parentElement.style.height = '100%'

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'expose:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @exposeView.destroy()

  serialize: ->
    exposeViewState: @exposeView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @exposeView.update()
      @modalPanel.show()
