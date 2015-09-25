Expose = require '../lib/expose'

describe "Expose", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('expose')

  describe "when the expose:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      expect(workspaceElement.querySelector('.expose-view')).not.toExist()

      atom.commands.dispatch workspaceElement, 'expose:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.expose-view')).toExist()

        exposeModule = atom.packages.loadedPackages['expose'].mainModule
        expect(exposeModule.modalPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'expose:toggle'
        expect(exposeModule.modalPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.expose-view')).not.toExist()

      atom.commands.dispatch workspaceElement, 'expose:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        exposeElement = workspaceElement.querySelector('.expose-view')
        expect(exposeElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'expose:toggle'
        expect(exposeElement).not.toBeVisible()

    it "disables animations with config", ->
      atom.commands.dispatch workspaceElement, 'expose:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        exposeElement = workspaceElement.querySelector('.expose-view')
        expect(exposeElement.classList.toString()).toContain 'animate'

        atom.commands.dispatch workspaceElement, 'expose:toggle'
        atom.config.set('expose.useAnimations', false)

        atom.commands.dispatch workspaceElement, 'expose:toggle'
        expect(exposeElement.classList.toString()).not.toContain 'animate'
