<template>
  <div>
    <input
        v-model="lastName"
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
    data: function () {
      return {
        lastName: ''
      }
    },
    watch: {
      value(newVal, oldVal) {
        if(newVal != oldVal)
          this.lastName = newVal
      },
      lastName(newVal) {
        this.$emit('input', newVal)
      }
    },
  }
</script>
