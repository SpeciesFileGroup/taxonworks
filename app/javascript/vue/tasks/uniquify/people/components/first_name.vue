<template>
  <div>
    <input vmodel="name_first" placeholder="first name">
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
        name_first
      }
    }
  }
</script>