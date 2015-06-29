{CompositeDisposable} = require 'atom'

ExposeView = require './expose-view'

module.exports = Expose =
  exposeView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @exposeView = new ExposeView(state.exposeViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @exposeView, visible: false, className: 'expose-panel')

    @subscriptions = new CompositeDisposable

    @subscriptions.add @modalPanel.onDidChangeVisible (visible) =>
      @exposeView.didChangeVisible(visible)

      # EXPERIMENTAL: Add blur effect to workspace when modal is visible.
      # This can be dangerous if onDidChangeVisible does not get triggered
      # for some reason. Then the blur effect is persistent on the workspace.
      workspaceView = atom.views.getView atom.workspace
      workspaceElement = workspaceView.getElementsByTagName('atom-workspace-axis')[0]
      workspaceElement.classList.toggle('expose-blur', visible)

    @subscriptions.add atom.commands.add 'atom-workspace',
      'expose:toggle': => @toggle()

  deactivate: ->
    @exposeView.destroy()
    @modalPanel.destroy()
    @subscriptions.dispose()

  serialize: ->
    exposeViewState: @exposeView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @exposeView.update()
      @modalPanel.show()
