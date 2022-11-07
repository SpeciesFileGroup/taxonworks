import { DATA_ATTRIBUTE_FILTER_PROPERTY } from 'constants/index.js'

function toJSON (str) {
  try {
    return JSON.parse(str)
  } catch (_) {
    return str
  }
}

export default () => {
  const parameters = {}
  const elements = [...document.querySelectorAll('*')]
    .filter(el => [...el.attributes].some(
      attr => attr.name.startsWith(DATA_ATTRIBUTE_FILTER_PROPERTY)
    ))

  elements.forEach(el => {
    const filterAttributes = el.getAttributeNames()
      .filter(attr => attr.startsWith(DATA_ATTRIBUTE_FILTER_PROPERTY))

    filterAttributes.forEach(attr => {
      const value = el.getAttribute(attr)
      const key = attr.substring(DATA_ATTRIBUTE_FILTER_PROPERTY.length + 1)
      const parameter = parameters[key]

      if (key in parameters) {
        if (Array.isArray(parameters)) {
          parameter.push(value)
        } else {
          parameters[key] = [parameter, value]
        }
      } else {
        const parsedValue = toJSON(value)
        const isArray = Array.isArray(parsedValue)

        if ((isArray && parsedValue.length) || !isArray) {
          parameters[key] = toJSON(value)
        }
      }
    })
  })

  return parameters
}
