<template>
  <div>
    <input vmodel="first_name" placeholder="first name">
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
        first_name
      }
    }
  }
</script>