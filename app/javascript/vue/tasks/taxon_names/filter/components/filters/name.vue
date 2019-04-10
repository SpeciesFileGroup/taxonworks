<template>
  <div>
    <h2>Name</h2>
    <div class="field">
      <label>Name</label>
      <input
        type="text"
        placeholder="Name"
        v-model="taxon.name">
    </div>
    <div class="field">
      <label>Author</label>
      <input
        type="text"
        placeholder="Author"
        v-model="taxon.author">
    </div>
    <div class="field">
      <label>Year</label>
      <input
        type="text"
        placeholder="Year"
        v-model="taxon.year">
    </div>
    <button
      type="button"
      class="button normal-input button-default">Search
    </button>
  </div>
</template>

<script>
export default {
  data() {
    return {
      taxon: {
        name: undefined,
        author: undefined,
        year: undefined
      }
    }
  }
}
</script>

<style lang="scss" scoped>
  .field {
    label {
      display: block;
    }
  }
</style>
