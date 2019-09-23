<template>
  <div>
    <h2>Determinations</h2>
    <h3>Otu</h3>
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Select an otu"
      param="term"
      label="label_html"
      display="label"
      @getItem="otu = $event" />
    <div class="field separate-top">
      <label>
        <input
          type="checkbox">
        Descendants (if available)
      </label>
    </div>
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