<template>
  <fieldset>
    <legend>{{ title || model }}</legend>
    <SmartSelector
      :model="model"
      :target="target"
      :klass="klass"
      :otu-picker="model === 'otus'"
      :label="label"
      @selected="(item) => (selectedItem = item)"
    />
    <hr v-if="selectedItem" />
    <SmartSelectorItem
      :item="selectedItem"
      :label="label"
      @unset="selectedItem = undefined"
    />
    <input
      type="text"
      class="d-none"
      :name="`${fieldObject}[${fieldProperty}]`"
      :value="inputValue"
    />
  </fieldset>
</template>

<script setup>
import { ref, computed, onBeforeMount } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'

const props = defineProps({
  currentObject: {
    type: Object,
    default: undefined
  },

  model: {
    type: String,
    required: true
  },

  target: {
    type: String,
    default: ''
  },

  klass: {
    type: String,
    default: ''
  },

  title: {
    type: String,
    default: ''
  },

  label: {
    type: String,
    default: 'object_tag'
  },

  objectType: {
    type: String,
    required: true
  },

  fieldObject: {
    type: String,
    required: true
  },

  fieldProperty: {
    type: String,
    required: true
  },

  objectProperty: {
    type: String,
    default: 'id'
  }
})

const selectedItem = ref()

const inputValue = computed(
  () => (selectedItem.value && selectedItem.value[props.objectProperty]) || null
)

onBeforeMount(() => {
  if (!props.currentObject) return

  selectedItem.value = props.currentObject
})
</script>

<style scoped>
hr {
  height: 1px;
  color: #f5f5f5;
  background: #f5f5f5;
  font-size: 0;
  margin: 15px;
  border: 0;
}
</style>
