<template>
  <div>
    <h3>New object attributes</h3>
    <div>
      <label>Total</label>
      <input type="number">
      <taxon-determination />
    </div>
  </div>
</template>

<script>

import TaxonDetermination from './determination'

export default {
  components: {
    TaxonDetermination
  }
}
</script>

<style scoped>
  label {
    display: block;
  }
</style>
