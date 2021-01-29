<template>
  <section>
    <autocomplete
      v-if="collectingEvent"
      url="/collecting_events/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search a collecting event"
      @getItem="setCE"/>
    <span
      v-else
      v-html="collectingEvent.object_tag"/>
  </section>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    collectingEvent: {
      type: Object,
      default: undefined
    }
  },
  methods: {
    setCE (ce) {
      this.$emit('onSelect', ce)
    }
  }
}
</script>
