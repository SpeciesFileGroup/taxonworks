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
        lastName: this.requestedPerson()
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
    methods: {
      requestedPerson() {
        if (window.location.href.split('last_name=')[1]) {
          return window.location.href.split('last_name=')[1];
        }
        else {
          return ''
        }
      },

    }
  }
</script>
