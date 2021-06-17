<template>
  <div class="expand-button">
    <span
      @click="$emit('update:modelValue', false)"
      data-icon="contract"
      title="Contract"
      v-if="value"/>
    <span
      @click="$emit('update:modelValue', true)"
      title="Expand"
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

<style scoped>
  .expand-button {
    cursor: pointer;
  }
</style>
