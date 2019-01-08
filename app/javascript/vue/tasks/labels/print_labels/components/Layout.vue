<template>
  <div>
    <h2>Layout</h2>
    <div class="field">
      <label class="label-layout-size">Rows</label>
      <input
        v-model="rows"
        type="number">
    </div>
    <div class="field">
      <label class="label-layout-size">Column</label>
      <input
        v-model="columns"
        type="number">
    </div>
    <div class="field">
      <label class="label-layout-size">Separator</label>
      <input
        v-model="separator"
        type="text">
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
  data() {
    return {
      rows: 0,
      columns: 0,
      separator: undefined
    }
  },
  watch: {
    rows(newVal) {
      this.$emit('onRowsChange', newVal)
    },
    columns(newVal) {
      this.$emit('onColumnsChange', newVal)
    },
    divisor(newVal) {
      this.$emit('onDivisorChange', newVal)
    },
  }
}
</script>

<style lang="scss" scoped>
  .label-layout-size {
    display: inline-block;
    min-width: 70px;
  }
</style>

