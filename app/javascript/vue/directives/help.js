const ARGS = {
  Path: 'path'
}

function setHelpPresent() {
  document.querySelector('.help-button')?.classList?.add('help-button-present')
}

function getLabelFromPath(json, path) {
  const properties = path.split('.')

  properties.forEach((property) => {
    json = json?.[property]
  })

  return json
}

function getLabelFromModifiers(json, modifiers) {
  for (const key in modifiers) {
    json = json[key]
  }

  return json
}

export const vHelp = {
  mounted(el, binding, vnode, oldVnode) {
    const { value, modifiers, arg, dir } = binding
    const { helpData = {} } = dir
    const hasModifiers = !!Object.keys(modifiers).length
    let description

    if (arg === ARGS.Path) {
      description = getLabelFromPath(helpData, value)
    } else if (hasModifiers) {
      description = getLabelFromModifiers(helpData, modifiers)
    } else {
      description = value
    }

    if (description) {
      el.setAttribute('data-help', description)
      setHelpPresent()
    }
  }
}
