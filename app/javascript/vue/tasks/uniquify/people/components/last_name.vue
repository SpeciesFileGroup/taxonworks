<template>
  <div>
    <input vmodel="last_name" placeholder="last name">
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
        last_name
      }
    }
  }
</script>