<template>
  <label class="switch">
    <input
      type="checkbox"
      v-model="inputValue">
    <div
      class="slider small round"
      :class="{ 'slider-active': inputValue } "/>
  </label>
</template>

<script>

export default {
  props: {
    value: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    inputValue: {
      get () {
        return this.value
      },
      set (newValue) {
        this.$emit('input', newValue)
      }
    }
  }
}
</script>

<style scoped>
  .slider {
    height: 28px;
  }
  .slider:before {
    height: 20px;
    width: 20px;
  }
  .switch {
    height: 24px;
    width: 40px;
  }
  .small {
    height: 24px;
  }

  .small:before {
    height: 16px;
    width: 16px;
  }
  input + .slider-active {
    background-color: #5D9ECE !important;
  }

  input + .slider-active::before {
    -webkit-transform: translateX(16px);
    -ms-transform: translateX(16px);
    transform: translateX(16px);
  }

  input + .slider {
    background-color: #F5F5F5;
  }
</style>
