<template>
  <div>
    <h3>Keywords</h3>
    <div class="field label-above">
      <label>Search text</label>
      <input
        type="text"
        class="full_width"
        name="source.query_term"
        v-model="source.query_term">
    </div>
    <div class="field label-above">
      <label>Title</label>
      <input
        type="text"
        class="full_width"
        name="source.title"
        v-model="source.title">
      <label class="horizontal-left-content">
        <input
          type="checkbox"
          v-model="source.exact_title">
        Exact
      </label>
    </div>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  computed: {
    source: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    this.source.title = urlParams.title
    this.source.exact_title = urlParams.exact_title
    this.source.query_term = urlParams.query_term
  }
}
</script>
