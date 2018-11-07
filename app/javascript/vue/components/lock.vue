<template>
  <div
    class="button-circle button-data"
    :class="{ 
      'btn-locked': locked,
      'btn-unlocked': !locked 
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
  data() {
    return {
      locked: false
    }
  },
  methods: {
    switchValue() {
      this.locked = !this.locked
      this.$emit('input', this.locked)
    }
  }
}
</script>
