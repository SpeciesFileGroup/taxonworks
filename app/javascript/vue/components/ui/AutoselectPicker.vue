<!-- AutoselectPicker.vue
  Opinionated, model-aware wrapper around AutoselectField — the Autoselect-framework
  analog of how SmartSelector relates to Autocomplete.vue, but deliberately narrower:
  AutoselectField already covers what SmartSelector exists to bolt onto Autocomplete
  (pinboard/recent are native operators, not something layered on top), so this adds
  only the two things AutoselectField leaves opt-in — the Preferences Options section
  and the !n create flow — as sensible per-model defaults. No id->full-object upgrade,
  no broadcast/lock, no tabs: this is not a SmartSelector clone.

  Props not declared here (placeholder, disabled, level-delay, id, reset-on-select,
  extra-params, autofocus, v-model, @select) fall through automatically onto the
  inner AutoselectField via Vue's single-root attrs/listener inheritance.
-->
<template>
  <AutoselectField
    :url="url"
    :param="param"
    :new-record-component="effectiveNewRecordComponent"
    :preferences-options-component="preferencesOptionsComponent"
  />
</template>

<script setup>
import { computed } from 'vue'
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
  preferencesOptionsComponent: { type: Object, default: () => ColDatasetPicker }
})

const url = computed(() => `/${props.model}/autoselect`)

const effectiveNewRecordComponent = computed(() => {
  if (!props.create) return null
  return props.createComponent ?? AUTOSELECT_NEW_RECORD_COMPONENTS[props.model] ?? null
})
</script>
