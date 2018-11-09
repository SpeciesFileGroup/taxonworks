
<template>
  <div>
    <h3>Collecting event</h3>
    <autocomplete
      url="/collecting_eventss/autocomplete"
      label="label_html"
      min="2"
      :clear-after="true"
      :autofocus="true"
      @getItem="sendCollectingEvent"
      placeholder="Select a gcollecting event"
      param="term"/>
  </div>
</template>

<script>

  import Autocomplete from '../../../../components/autocomplete.vue'

  export default {
    components: {
      Autocomplete
    },
    props: {
      createdList: {
        type: Array,
        required: true
      }
    },
    data() {
      return {
        selected: undefined
      }
    },
    mounted() {
    },
    methods: {
      sendCollectingEvent(item) {
        this.selected = ''
        this.$emit('select', item.id)
      }
    }
  }
</script>
