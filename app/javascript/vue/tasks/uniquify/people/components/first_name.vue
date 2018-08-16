<template>
  <div>
    <input
      v-model="firstName"
      placeholder="search is wild card wrapped"/>
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
        firstName: ''
      }
    },
    watch: {
      value(newVal, oldVal) {
        if(newVal != oldVal)
          this.firstName = newVal
      },
      firstName(newVal) {
        this.$emit('input', newVal)
      }
    }
  }
</script>
