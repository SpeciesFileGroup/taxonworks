<template>
  <div
    class="button-circle button-data"
    :class="{ 
      'btn-locked': value,
      'btn-unlocked': !value 
    }"
    @click="switchValue"
  />
</template>

<script>
export default {
  props: {
    value: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    switchValue() {
      this.$emit('input', !this.value)
    }
  }
}
</script>
