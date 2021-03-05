<template>
  <div>
    <h2>Buffered</h2>
    <div
      v-for="(item, key) in buffered"
      class="field label-above">
      <label class="capitalize">{{ key.replace('buffered_', '').replace(/_/g, ' ') }}</label>
      <input
        class="full_width"
        v-model="buffered[key]"
        type="text">
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
    const { buffered_collecting_event, buffered_determinations, buffered_other_labels } = URLParamsToJSON(location.href)
    this.buffered = {
      buffered_collecting_event,
      buffered_determinations,
      buffered_other_labels
    }
  }
}
</script>
