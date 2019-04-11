<template>
  <div>
    <h2>Taxon</h2>
    <div class="field">
      <label>Name</label>
      <input
        type="text"
        placeholder="Name"
        class="full_width"
        @keyup.enter="$emit('onSearch')"
        v-model="value.name">
    </div>
    <div class="field">
      <label>Author</label>
      <input
        type="text"
        class="full_width"
        placeholder="Author"
        @keyup.enter="$emit('onSearch')"
        v-model="value.author">
    </div>
    <div class="field">
      <label>Year</label>
      <input
        class="field-year"
        type="text"
        placeholder="Year"
        @keyup.enter="$emit('onSearch')"
        v-model="value.year">
    </div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="$emit('onSearch')">Search
    </button>
  </div>
</template>

<script>
export default {
  props: {
    value: {

    }
  },
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
  .field-year {
    width: 60px;
  }

</style>
