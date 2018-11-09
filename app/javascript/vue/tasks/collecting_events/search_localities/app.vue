<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h1>Search and List Localities</h1>
    <h3>Collecting event</h3>
    <autocomplete
      url="/collecting_events/autocomplete"
      label="label_html"
      min="2"
      :clear-after="true"
      :autofocus="true"
      @getItem="sendCollectingEvent"
      placeholder="Select a collecting event"
      param="term"/>
    <alphabet-buttons
      @keypress="getLocalities($event)"
      ref="alphabetButtons"/>
  </div>
</template>
<script>
  import AlphabetButtons from './components/alphabet_buttons'
  import Spinner from '../../../components/spinner.vue'
  import Autocomplete from '../../../components/autocomplete.vue'

  export default {
    components: {
      AlphabetButtons,
      Spinner,
      Autocomplete
    },
    data() {
      return {
        isLoading: false,
        letter: '',
        selected: undefined,
        localityList: []
      }
    },
    mounted() {
    },
    methods: {
      sendCollectingEvent(item) {
        this.selected = item
      }
    }
  }
</script>
