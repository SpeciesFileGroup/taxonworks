import { createApp } from 'vue'
import App from './App.vue'
import { AUTOSELECT_NEW_RECORD_COMPONENTS } from '@/components/ui/AutoselectField/newRecordComponents'
import ColDatasetPicker from '@/components/ui/AutoselectField/ColDatasetPicker.vue'

// Keyed by class name here (matches the data-autoselect-new-record-component attribute
// value authors write in ERB), unlike the model-keyed shared map it's built from.
const NEW_RECORD_COMPONENTS = {
  OtuNewModal: AUTOSELECT_NEW_RECORD_COMPONENTS.otus,
  TaxonNameNewModal: AUTOSELECT_NEW_RECORD_COMPONENTS.taxon_names
}

const PREFERENCES_OPTIONS_COMPONENTS = {
  ColDatasetPicker
}

function removeEmptyProps(props) {
  const obj = { ...props }

  for (const key in obj) {
    if (obj[key] === null) {
      delete obj[key]
    }
  }

  return obj
}

function makeCurrentObject(value, label, param) {
  return value
    ? {
        id: Number(value),
        label_html: label,
        response_values: { [param]: Number(value) }
      }
    : null
}

function init(element) {
  const url = element.getAttribute('data-autoselect-url')
  const param = element.getAttribute('data-autoselect-param')
  const fieldObject = element.getAttribute('data-autoselect-field-object')
  const fieldProperty = element.getAttribute('data-autoselect-field-property')
  const id = element.getAttribute('data-autoselect-id')
  const placeholder = element.getAttribute('data-autoselect-placeholder')
  const disabled = element.getAttribute('data-autoselect-disabled')
  const levelDelay = element.getAttribute('data-autoselect-level-delay')
  const currentValue = element.getAttribute('data-autoselect-current-value')
  const currentLabel = element.getAttribute('data-autoselect-current-label')
  const newRecordComponent = element.getAttribute(
    'data-autoselect-new-record-component'
  )
  const preferencesOptionsComponent = element.getAttribute(
    'data-autoselect-preferences-options-component'
  )

  const props = removeEmptyProps({
    url,
    param,
    fieldObject,
    fieldProperty,
    id,
    placeholder,
    disabled: disabled === 'true' ? true : null,
    levelDelay: levelDelay ? Number(levelDelay) : null,
    currentObject: makeCurrentObject(currentValue, currentLabel, param),
    newRecordComponent: NEW_RECORD_COMPONENTS[newRecordComponent] || null,
    preferencesOptionsComponent:
      PREFERENCES_OPTIONS_COMPONENTS[preferencesOptionsComponent] || null
  })

  const app = createApp(App, props)

  app.mount(element)
}

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('[data-autoselect]').forEach((element) => {
    init(element)
  })
})
