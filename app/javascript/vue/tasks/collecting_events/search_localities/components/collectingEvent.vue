
<template>
  <div>
    <h3>Collecting event</h3>
    <autocomplete
      url="/collecting_events/autocomplete"
      min="2"
      label="label_html"
      placeholder="Select a place name"
      :autofocus="true"
      @getItem="sendCollectingEvent"
      display="label"
      param="term"/>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'

  export default {
    components: {
      Autocomplete
    },
    data() {
      return {
        selectedEvent: undefined
      }
    },
    mounted() {
    },
    methods: {
      sendCollectingEvent(item) {
        this.selectedEvent=item.id;
        this.$emit('selectedEvent', item.id)
      }
    }
  }
</script>
