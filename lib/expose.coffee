{CompositeDisposable} = require 'atom'

ExposeView = require './expose-view'

module.exports = Expose =
  exposeView: null
  modalPanel: null

  config:
    useAnimations:
      type: 'boolean'
      default: true

  activate: ->
    @exposeView = new ExposeView
    @modalPanel = atom.workspace.addModalPanel(item: @exposeView, visible: false, className: 'expose-panel')

    @disposables = new CompositeDisposable

    @disposables.add @modalPanel.onDidChangeVisible (visible) =>
      @exposeView.didChangeVisible(visible)

      # EXPERIMENTAL: Add blur effect to workspace when modal is visible.
      # This can be dangerous if onDidChangeVisible does not get triggered
      # for some reason. Then the blur effect is persistent on the workspace.
      workspaceView = atom.views.getView atom.workspace
      workspaceElement = workspaceView.getElementsByTagName('atom-workspace-axis')[0]
      visible = false unless atom.config.get 'expose.useAnimations'
      workspaceElement.classList.toggle('expose-blur', visible)

    @disposables.add atom.commands.add 'atom-workspace',
      'expose:toggle': => @toggle()

  deactivate: ->
    @exposeView.destroy()
    @modalPanel.destroy()
    @disposables.dispose()

  toggle: ->
    if @modalPanel.isVisible()
      @exposeView.exposeHide()
    else
      @modalPanel.show()
