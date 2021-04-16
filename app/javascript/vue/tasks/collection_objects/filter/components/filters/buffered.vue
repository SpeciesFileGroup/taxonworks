<template>
  <div>
    <h3>Buffered</h3>
    <div
      v-for="(item, key) in buffered.text"
      class="field label-above">
      <label class="capitalize">{{ key.replace('buffered_', '').replace(/_/g, ' ') }}</label>
      <input
        class="full_width"
        v-model="buffered.text[key]"
        type="text">
      <label>
        <input
          v-model="buffered.exact[`exact_${key}`]"
          type="checkbox">
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
      required: true
    }
  },

  computed: {
    buffered: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },

  created () {
    const { buffered_collecting_event, buffered_determinations, buffered_other_labels, exact_buffered_collecting_event, exact_buffered_determinations, exact_buffered_other_labels } = URLParamsToJSON(location.href)
    this.buffered.text = {
      buffered_collecting_event,
      buffered_determinations,
      buffered_other_labels
    }
    this.buffered.exact = {
      exact_buffered_collecting_event,
      exact_buffered_determinations,
      exact_buffered_other_labels
    }
  }
}
</script>
