<template>
  <fieldset>
    <legend>Geographic area</legend>
    <div class="horizontal-left-content align-start">
      <smart-selector
        v-model="geographicArea"
        class="full_width"
        model="geographic_areas"
        klass="AssertedDistribution"
        target="AssertedDistribution"
        label="name"
        pin-section="GeographicAreas"
        @selected="onSelect"
        pin-type="GeographicArea"
      />
      <VLock
        v-model="lock"
        class="margin-small-left"
      />
    </div>
    <SmartSelectorItem
      :item="geographicArea"
      label="name"
      @unset="geographicArea = undefined"
    />
  </fieldset>
</template>

<script setup>
import { computed } from 'vue'
import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VLock from 'components/ui/VLock/index.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  lock: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits([
  'update:modelValue',
  'update:lock',
  'selected'
])

const geographicArea = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

const lock = computed({
  get: () => props.lock,
  set: value => emit('update:lock', value)
})

const onSelect = geo => {
  geographicArea.value = geo
  emit('selected')
}
</script>