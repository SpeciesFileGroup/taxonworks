<!-- AutoselectPicker.vue
  Opinionated, model-aware wrapper around AutoselectField — the Autoselect-framework
  analog of how SmartSelector relates to Autocomplete.vue, but deliberately narrower:
  AutoselectField already covers most of what SmartSelector exists to bolt onto
  Autocomplete (pinboard/recent are native operators, not something layered on top).
  This adds the things AutoselectField leaves opt-in — the Preferences Options
  section, the !n create flow, and (opt-in) the id->full-object upgrade SmartSelector
  calls `getObject` — as sensible per-model defaults/lookups. Still no broadcast/lock,
  no tabs: this is not a full SmartSelector clone.

  Props not declared here (placeholder, disabled, level-delay, id, reset-on-select,
  extra-params, autofocus) fall through automatically onto the inner AutoselectField
  via Vue's single-root attrs inheritance. `select` and `update:modelValue` are
  declared explicitly (see below) so they can be intercepted for the getObject
  upgrade, so they do NOT rely on fallthrough.
-->
<template>
  <AutoselectField
    :url="url"
    :param="param"
    :new-record-component="effectiveNewRecordComponent"
    :preferences-options-component="preferencesOptionsComponent"
    @select="onSelect"
    @update:model-value="onModelValueUpdate"
  />
</template>

<script setup>
import { computed } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import ColDatasetPicker from '@/components/ui/AutoselectField/ColDatasetPicker.vue'
import { AUTOSELECT_NEW_RECORD_COMPONENTS } from '@/components/ui/AutoselectField/newRecordComponents'

const props = defineProps({
  // Drives the autoselect url (`/${model}/autoselect`) and the create-component
  // lookup, e.g. 'otus', 'taxon_names'.
  model: { type: String, required: true },
  param: { type: String, required: true },
  // When true (default), the !n modal is resolved from AUTOSELECT_NEW_RECORD_COMPONENTS
  // by model unless createComponent overrides it. When false, !n is disabled outright.
  create: { type: Boolean, default: true },
  // Explicit override for the resolved create component; wins over the model lookup.
  createComponent: { type: Object, default: null },
  // Defaults to ColDatasetPicker (every current autoselect model includes a
  // catalogue_of_life level); pass null to omit the Options section, or a different
  // component to replace it.
  preferencesOptionsComponent: { type: Object, default: () => ColDatasetPicker },
  // When true, `select`/`update:modelValue` receive the full fetched record
  // (GET `/${model}/${id}.json`, or `getUrl` if given) instead of the lightweight
  // autoselect response item. Mirrors SmartSelector's `getObject`. Off by default —
  // most callers only need `response_values`, not a full record round trip.
  getObject: { type: Boolean, default: false },
  // Overrides the default `/${model}/` fetch prefix used when getObject is true.
  getUrl: { type: String, default: null },
  // Extra params merged into the getObject fetch request (e.g. `{ extend: [...] }`).
  fetchParams: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['select', 'update:modelValue'])

const url = computed(() => `/${props.model}/autoselect`)

const effectiveNewRecordComponent = computed(() => {
  if (!props.create) return null
  return props.createComponent ?? AUTOSELECT_NEW_RECORD_COMPONENTS[props.model] ?? null
})

function onSelect(item, searchText) {
  if (!props.getObject || !item?.id) {
    emit('select', item, searchText)
    emit('update:modelValue', item)
    return
  }

  const prefix = props.getUrl ?? `/${props.model}/`

  AjaxCall('get', `${prefix}${item.id}.json`, { params: props.fetchParams })
    .then(({ body }) => {
      emit('select', body, searchText)
      emit('update:modelValue', body)
    })
    .catch(() => {})
}

// AutoselectField also emits update:modelValue(null) on clear, independent of select.
// A real selection is handled by onSelect above (possibly after an async upgrade), so
// only forward the clear case here to avoid a stale/duplicate emit racing the fetch.
function onModelValueUpdate(item) {
  if (item !== null) return
  emit('update:modelValue', null)
}
</script>
