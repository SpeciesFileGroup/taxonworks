import { createApp } from 'vue'
import App from './App.vue'

function removeEmptyProps(props) {
  const obj = { ...props }

  for (const key in obj) {
    if (obj[key] === null) {
      delete obj[key]
    }
  }

  return obj
}

function makeCurrentObject(id, label, objectLabel) {
  return id && label
    ? {
        id: Number(id),
        [objectLabel]: label
      }
    : null
}

function init(element) {
  const model = element.getAttribute('data-smart-selector-model')
  const target = element.getAttribute('data-smart-selector-target')
  const klass = element.getAttribute('data-smart-selector-klass')
  const fieldObject = element.getAttribute('data-smart-selector-field-object')
  const objectLabelProperty = element.getAttribute('data-smart-selector-object-label')
  const fieldProperty = element.getAttribute('data-smart-selector-field-property')
  const objectProperty = element.getAttribute('data-smart-selector-object-property')
  const title = element.getAttribute('data-smart-selector-title')
  const currentObjectId = element.getAttribute('data-smart-selector-current-object-id')
  const currentObjectLabel = element.getAttribute('data-smart-selector-current-object-label')

  const props = removeEmptyProps({
    model,
    target,
    klass,
    fieldObject,
    objectProperty,
    fieldProperty,
    title,
    currentObject: makeCurrentObject(
      currentObjectId,
      currentObjectLabel,
      objectLabelProperty || 'object_tag'
    )
  })

  const app = createApp(App, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  if (document.querySelector('[data-smart-selector]')) {
    document.querySelectorAll('[data-smart-selector]').forEach((element) => {
      init(element)
    })
  }
})
