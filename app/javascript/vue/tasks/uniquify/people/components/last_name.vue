<template>
  <div>
    <input
        v-model="lastName"
        placeholder="last name"/>
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
          this.firstName = newVal
      },
      first_name(newVal) {
        this.$emit('input', newVal)
      }
    }
  }
</script>
