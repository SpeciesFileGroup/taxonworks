<template>
  <div>
    <h2>Layout</h2>
    <div class="field">
      <label class="label-layout-size">Rows</label>
      <input type="number">
    </div>
    <div class="field">
      <label class="label-layout-size">Column</label>
      <input type="number">
    </div>
    <div class="field">
      <label class="label-layout-size">Separator</label>
      <input type="text">
      <button
        type="button"
        class="button normal-input button-default">
        Clear
      </button>
    </div>
    <label>
      <input 
        type="checkbox">
      Blank lines with line divider
    </label>
  </div>
</template>
<script>
export default {
  
}
</script>

<style lang="scss" scoped>
  .label-layout-size {
    display: inline-block;
    min-width: 70px;
  }
</style>

