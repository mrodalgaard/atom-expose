{View} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

ExposeTabView = require './expose-tab-view'
{exposeHide} = require './util'

module.exports =
class ExposeView extends View
  @content: ->
    @div class: 'expose-view animate', =>
      @div class: 'expose-top', =>
        @a outlet: 'exposeSettings', class: 'icon-gear'
        @a outlet: 'exposeHide', class: 'icon-x'
      @div outlet: 'tabList', class: 'tab-bar'

  constructor: (serializedState) ->
    super
    @disposables = new CompositeDisposable

    @exposeHide.on 'click', exposeHide
    @exposeSettings.on 'click', ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'settings-view:view-installed-packages')
      exposeHide()

  serialize: ->

  destroy: ->
    @remove()
    @disposables?.dispose()

  didChangeVisible: (visible) ->
    setTimeout (=> @element.classList.toggle('visible', visible)), 0

  update: ->
    @tabList.empty()
    for item in atom.workspace.getPaneItems()
      @tabList.append new ExposeTabView(item)
