module.exports =
  exposeHide: ->
    for panel in atom.workspace.getModalPanels()
      panel.hide() if panel.className is 'expose-panel'
