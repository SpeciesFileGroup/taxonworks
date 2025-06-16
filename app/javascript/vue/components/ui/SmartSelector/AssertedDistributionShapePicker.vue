<template>
  <div>
    <PolymorphicObjectPicker
      :object-types="AssertedDistributionShape"
      v-model="inputShape"
      :minimal="minimal"
      :autofocus="autofocus"
      :focus-on-select="focusOnSelect"
      :label="label"
      klass-key="shapeType"
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
import AssertedDistributionShape from './PolymorphicObjectPicker/PolymorphismClasses/AssertedDistributionShape.js'

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

const inputShape = defineModel({
  type: Object,
  default: () => ({})
})

const emit = defineEmits(['selectObject'])

</script>
