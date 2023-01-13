<template>
  <div>
    <span
      @click="$emit('update:modelValue', false)"
      data-icon="contract"
      v-if="modelValue"/>
    <span
      @click="$emit('update:modelValue', true)"
      data-icon="expand"
      v-else/>
  </div>
</template>
<script>

export default {
  props: {
    modelValue: {
      type: Boolean,
      default: true
    }
  },

  emits: ['update:modelValue']
}
</script>
