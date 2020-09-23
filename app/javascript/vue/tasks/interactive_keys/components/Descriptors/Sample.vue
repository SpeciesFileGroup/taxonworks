<template>
  <div>
    <label></label>
    <input type="number">
  </div>
</template>

<script>
export default {
  props: {
    descriptor: {
      type: Object,
      required: true
    }
  }
}
</script>
