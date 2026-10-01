<!-- AutoselectPicker.vue
  Opinionated, model-aware wrapper around AutoselectField — the Autoselect-framework
  analog of how SmartSelector relates to Autocomplete.vue, but deliberately narrower:
  AutoselectField already covers most of what SmartSelector exists to bolt onto
  Autocomplete (pinboard/recent are native operators, not something layered on top).
  This adds the things AutoselectField leaves opt-in — the Preferences Options
  section, the !n create flow, and (opt-in) the id->full-object upgrade SmartSelector
  calls `getObject` — as sensible per-model defaults/lookups. Still no broadcast/lock,
  no tabs: this is not a full SmartSelector clone.
-->
<template>
  <AutoselectField
    ref="autoselectFieldRef"
    :url="url"
    :param="param"
    :reset-on-select="resetOnSelect"
    :new-record-component="effectiveNewRecordComponent"
    :preferences-options-component="preferencesOptionsComponent"
    @select="onSelect"
  />
</template>

<script setup>
import { computed, useTemplateRef } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import ColDatasetPicker from '@/components/ui/AutoselectField/ColDatasetPicker.vue'
import { AUTOSELECT_NEW_RECORD_COMPONENTS } from '@/components/ui/AutoselectField/newRecordComponents'

const props = defineProps({
  // Drives the autoselect url (`/${model}/autoselect`) and the create-component
  // lookup, e.g. 'otus', 'taxon_names'.
  model: { type: String, required: true },
  param: { type: String, required: true },
  // Clear the field and return to level 0 after each pick instead of leaving the
  // selected label in the input. AutoselectField defaults this off; the picker flips
  // it on because its consumers (SmartSelector's OTU picker, the assign/match result
  // tables) are append-to-list or pick-then-act flows that want the field ready for
  // the next search. Pass :reset-on-select="false" to opt out.
  resetOnSelect: { type: Boolean, default: true },
  // When true (default), the !n modal is resolved from AUTOSELECT_NEW_RECORD_COMPONENTS
  // by model unless createComponent overrides it. When false, !n is disabled outright.
  create: { type: Boolean, default: true },
  // Explicit override for the resolved create component; wins over the model lookup.
  createComponent: { type: Object, default: null },
  // Defaults to ColDatasetPicker (every current autoselect model includes a
  // catalogue_of_life level); pass null to omit the Options section, or a different
  // component to replace it.
  preferencesOptionsComponent: { type: Object, default: () => ColDatasetPicker },
  // When true, `select` receives the full fetched record
  // (GET `/${model}/${id}.json`, or `getUrl` if given) instead of the lightweight
  // autoselect response item. Mirrors SmartSelector's `getObject`. Off by default —
  // most callers only need `response_values`, not a full record round trip.
  getObject: { type: Boolean, default: false },
  // Overrides the default `/${model}/` fetch prefix used when getObject is true.
  getUrl: { type: String, default: null },
  // Extra params merged into the getObject fetch request (e.g. `{ extend: [...] }`).
  fetchParams: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['select'])

const url = computed(() => `/${props.model}/autoselect`)

const effectiveNewRecordComponent = computed(() => {
  if (!props.create) return null
  return props.createComponent ?? AUTOSELECT_NEW_RECORD_COMPONENTS[props.model] ?? null
})

function onSelect(item, searchText) {
  if (!props.getObject || !item?.id) {
    emit('select', item, searchText)
    return
  }

  const prefix = props.getUrl ?? `/${props.model}/`

  AjaxCall('get', `${prefix}${item.id}.json`, { params: props.fetchParams })
    .then(({ body }) => {
      emit('select', body, searchText)
    })
    .catch(() => {})
}

const autoselectFieldRef = useTemplateRef('autoselectFieldRef')

// AutoselectField exposes prefill but has no focus method of its own, so reach
// straight into the DOM.
function setFocus() {
  autoselectFieldRef.value?.$el?.querySelector('input')?.focus()
}

defineExpose({
  setFocus,
  prefill: (...args) => autoselectFieldRef.value?.prefill(...args),
  getSearchText: () => autoselectFieldRef.value?.getSearchText() ?? ''
})
</script>
