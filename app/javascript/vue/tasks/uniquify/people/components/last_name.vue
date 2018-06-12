<template>
  <div>
    <input vmodel="lastName" placeholder="last name">
  </div>
</template>
<script>
  export default {
    props: {
      value: {
        type: String,
        value: ''
      }
    },
    data: function () {
      return {
        lastName
      }
    }
  }
</script>