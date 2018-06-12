<template>
  <div>
    <input
      v-model="firstName"
      placeholder="first name">
  </div>
</template>
<script>
  export default {
    props: {
      value: {
        type: String,
        default: ''
      }
    },
    data() {
      return {
        first_name: ''
      }
    },
    watch: {
      value(newVal, oldVal) {
        if(newVal != oldVal)
          this.firstName = newVal
      },
      first_name(newVal) {
        this.$emit('input', newVal)
      }
    }
  }
</script>