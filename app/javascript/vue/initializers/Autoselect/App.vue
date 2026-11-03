<template>
  <div class="autoselect-mount">
    <AutoselectPicker
      v-if="!selectedItem"
      :id="id"
      :model="model"
      :param="param"
      :placeholder="placeholder"
      :disabled="disabled"
      :level-delay="levelDelay"
      :create-component="newRecordComponent"
      :preferences-options-component="preferencesOptionsComponent"
      @select="selectedItem = $event"
    />
    <SmartSelectorItem
      v-else
      :item="selectedItem"
      label="label_html"
      @unset="selectedItem = null"
    />
    <input
      type="hidden"
      :name="inputName"
      :value="inputValue"
    />
  </div>
</template>

<script setup>
import { ref, computed, onBeforeMount } from 'vue'
import AutoselectPicker from '@/components/ui/AutoselectPicker.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  // Drives AutoselectPicker's url and create-component lookup, e.g. 'otus', 'taxon_names'.
  model: {
    type: String,
    required: true
  },

  param: {
    type: String,
    required: true
  },

  fieldObject: {
    type: String,
    default: ''
  },

  fieldProperty: {
    type: String,
    required: true
  },

  currentObject: {
    type: Object,
    default: null
  },

  id: {
    type: String,
    default: null
  },

  placeholder: {
    type: String,
    default: 'Search...'
  },

  disabled: {
    type: Boolean,
    default: false
  },

  levelDelay: {
    type: Number,
    default: 500
  },

  // Forwarded to AutoselectPicker's createComponent (overrides its model-based
  // lookup); leave unset to get that model-appropriate !n modal automatically.
  newRecordComponent: {
    type: Object,
    default: null
  },

  // Left undefined (not null) when unset, so main.js's removeEmptyProps stripping
  // this key results in AutoselectPicker's own ColDatasetPicker default applying —
  // an explicit null here would instead force the Options section off.
  preferencesOptionsComponent: {
    type: Object,
    default: undefined
  }
})

const selectedItem = ref(null)

const inputName = computed(() =>
  props.fieldObject
    ? `${props.fieldObject}[${props.fieldProperty}]`
    : props.fieldProperty
)

const inputValue = computed(() => {
  const item = selectedItem.value

  if (!item) return ''

  return item.response_values?.[props.param] ?? item.id ?? ''
})

onBeforeMount(() => {
  selectedItem.value = props.currentObject
})
</script>
