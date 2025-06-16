<template>
  <div>
    <PolymorphicObjectPicker
      :object-types="AssertedDistributionShape"
      v-model="inputShape"
      :minimal="minimal"
      :autofocus="autofocus"
      :focus-on-select="focusOnSelect"
      @select-object="(o) => { emit('selectObject', o) }"
    />
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
  }
})

const inputShape = defineModel({
  type: Object,
  default: () => ({})
})

const emit = defineEmits(['selectObject'])

</script>
