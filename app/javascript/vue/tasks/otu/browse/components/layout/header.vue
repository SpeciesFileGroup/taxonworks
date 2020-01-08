<template>
  <div class="panel full_width">
    <div class="panel content container">
    </div>
  </div>
</template>

<script>
export default {
  props: {
    otu: {
      type: Object,
      default: undefined
    }
  }
}
</script>

<style>
  .container {
    margin: 0 auto;
    width: 1280px;
  }
</style>