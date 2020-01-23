<template>
  <fieldset>
    <legend>Collecting Event</legend>
    <smart-selector
    model="collecting_events"
    klass="CollectingEvent"/>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/smartSelector'

export default {
  components: {
    SmartSelector
  },
  data () {
    return {
      tabs: [],
      lists: undefined,
      view: undefined
    }
  },
  methods: {

  }
}
</script>
