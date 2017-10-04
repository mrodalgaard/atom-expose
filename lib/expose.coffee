{CompositeDisposable, Disposable} = require 'atom'

ExposeView = require './expose-view'
FileIcons = require './file-icons'

module.exports = Expose =
  exposeView: null
  modalPanel: null

  activate: ->
    @exposeView = new ExposeView
    @modalPanel = atom.workspace.addModalPanel(item: @exposeView, visible: false, className: 'expose-panel')

    @disposables = new CompositeDisposable

    @disposables.add @modalPanel.onDidChangeVisible (visible) =>
      @exposeView.didChangeVisible(visible)

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

  consumeFileIcons: (service) ->
    FileIcons.setService(service)
    @exposeView.updateFileIcons()
    new Disposable =>
      FileIcons.resetService()
      @exposeView.updateFileIcons()
