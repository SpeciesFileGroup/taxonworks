let HelpSystem = {}
let languages = {}
let defaultLanguage = ''

const getString = function(modifiers) {
  if(!Object.keys(modifiers).length) return false

  let string = languages[defaultLanguage]

  for(let key in modifiers) {
    if(string.hasOwnProperty(key)) {
      string = string[key]
    }
    else {
      string = undefined
      break;
    }
  }

  return string
}

const setHelpPresent = function() {
  document.querySelector('.help-button').classList.add('help-button-present')
}

HelpSystem.install = function (Vue, options) {
  languages = options.languages
  
  if(options.default) {
    defaultLanguage = options.default
  }
  else {
    defaultLanguage = Object.keys(languages)[0]
  }

  Vue.directive('help', {
    bind (el, binding, vnode, oldVnode) {
      if(languages.hasOwnProperty(defaultLanguage)) {
        let description = getString(binding.modifiers)
        if(description) {
          el.setAttribute('data-help', description);
          setHelpPresent();
        }
      }
    }
  })
}

export default HelpSystem