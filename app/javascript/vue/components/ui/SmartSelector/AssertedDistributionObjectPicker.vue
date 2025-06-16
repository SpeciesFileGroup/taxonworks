<template>
  <div>
    <PolymorphicObjectPicker
      :object-types="AssertedDistributionObject"
      v-model="inputObject"
      :minimal="minimal"
      :autofocus="autofocus"
      :focus-on-select="focusOnSelect"
      :label="label"
      @select-object="(o) => { emit('selectObject', o) }"
    >
      <template #tabs-right>
        <slot name="tabs-right" />
      </template>
    </PolymorphicObjectPicker>
  </div>
</template>

<script setup>
import PolymorphicObjectPicker from './PolymorphicObjectPicker/PolymorphicObjectPicker.vue'
import AssertedDistributionObject from './PolymorphicObjectPicker/PolymorphismClasses/AssertedDistributionObject'

const props = defineProps({
  minimal: {
    type: Boolean,
    default: false
  },

  focusOnSelect: {
    type: Boolean,
    default: false
  },

  autofocus: {
    type: Boolean,
    default: false
  },

  label: {
    type: String,
    required: false
  }
})

const inputObject = defineModel({
  type: Object,
  default: () => ({})
})

const emit = defineEmits(['selectObject'])

</script>
