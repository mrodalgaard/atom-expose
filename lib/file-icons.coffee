class FileIcons
  constructor: ->
    @service = new DefaultFileIcons

  getService: ->
    @service

  resetService: ->
    @service = new DefaultFileIcons

  setService: (@service) ->

class DefaultFileIcons
  iconClassForPath: (filePath) ->
    ''

module.exports = new FileIcons
