<template>
  <div>
    <input vmodel="name_last" placeholder="last name">
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
        name_last
      }
    }
  }
</script>