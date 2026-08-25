<template>
  <div class="autoselect-mount">
    <AutoselectField
      v-if="!selectedItem"
      :id="id"
      :url="url"
      :param="param"
      :placeholder="placeholder"
      :disabled="disabled"
      :level-delay="levelDelay"
      :new-record-component="newRecordComponent"
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
import AutoselectField from '@/components/ui/AutoselectField.vue'
import ColDatasetPicker from '@/components/ui/AutoselectField/ColDatasetPicker.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  url: {
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

  newRecordComponent: {
    type: Object,
    default: null
  },

  // main.js's removeEmptyProps strips this key entirely when the mounting element has
  // no data-autoselect-preferences-options-component attribute, so this default (not
  // main.js's own null fallback) is what actually governs the un-customized case.
  preferencesOptionsComponent: {
    type: Object,
    default: () => ColDatasetPicker
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
