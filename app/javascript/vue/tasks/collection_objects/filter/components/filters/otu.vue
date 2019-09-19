<template>
  <div>
    <h2>Otu</h2>
    <div class="field">
      <label>
        <input
          type="checkbox">
        Descendants (if available)
      </label>
    </div>
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Select an otu"
      param="term"
      label="label_html"
      display="label"
      @getItem="otu = $event" />
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    otuId: {
      type: [Number, String],
      default: undefined
    }
  },
  computed: {
    otu: {
      get () {
        return this.otuId
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  }
}
</script>