<template>
  <div class="panel content full_width">
    <autocomplete
      url="/otus/autocomplete"
      placeholder="Search a otu"
      param="term"
      @getItem="sendOtu"
      :clear-after="true"
      label="label_html"/>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'

export default {
  components: {
    Autocomplete
  },
  methods: {
    sendOtu (otu) {
      this.$emit('onOtuSelect', otu)
    }
  }
}
</script>
