const HelpSystem = {}
let languages = {}
let defaultLanguage = ''

const getString = function(binding) {
  const modifiers = binding.modifiers
  let string = languages[defaultLanguage]

  if (binding.hasOwnProperty('expression')) {
    const expression = binding.value.split('.')

    expression.forEach(item => {
      string = string[item]
    })
    return string
  }

  for (const key in modifiers) {
    if (string.hasOwnProperty(key)) {
      string = string[key]
    } else {
      string = undefined
      break
    }
  }

  return string
}

const setHelpPresent = () => {
  document.querySelector('.help-button').classList.add('help-button-present')
}

HelpSystem.install = function (app, options) {
  languages = options.languages
  defaultLanguage = options.default || Object.keys(languages)[0]

  app.directive('help', {
    beforeMount (el, binding, vnode, oldVnode) {
      if (languages.hasOwnProperty(defaultLanguage)) {
        const description = getString(binding)

        if (description) {
          el.setAttribute('data-help', description)
          setHelpPresent()
        }
      }
    }
  })
}

export default HelpSystem
