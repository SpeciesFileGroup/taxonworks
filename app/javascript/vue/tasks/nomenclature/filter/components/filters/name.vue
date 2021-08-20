<template>
  <div>
    <h3>Taxon</h3>
    <div class="field">
      <label>Name</label>
      <input
        type="text"
        placeholder="Name"
        class="full_width"
        @keyup.enter="$emit('onSearch')"
        v-model="taxon.name">
    </div>
    <div class="field">
      <label>Author</label>
      <input
        type="text"
        class="full_width"
        placeholder="Author"
        @keyup.enter="$emit('onSearch')"
        v-model="taxon.author">
    </div>
    <div class="field">
      <label>Year</label>
      <input
        class="field-year"
        type="text"
        placeholder="Year"
        @keyup.enter="$emit('onSearch')"
        v-model="taxon.year">
    </div>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    taxon: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  mounted () {
    const params = URLParamsToJSON(location.href)

    this.taxon.name = params.name
    this.taxon.author = params.author
    this.taxon.year = params.year
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
