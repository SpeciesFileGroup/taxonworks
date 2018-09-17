<template>
  <div>
    <span
      v-if="showMessage"
      class="warning-validation" 
      data-icon="warning"/>
  </div>
</template>
<script>
  export default {
    props: {
      showMessage: {
        type: Boolean,
        default: false
      }
    }
  }
</script>
<style scoped>
  .warning-validation {
    cursor: pointer;
  }
</style>
