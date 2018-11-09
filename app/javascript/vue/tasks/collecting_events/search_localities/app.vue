<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h1>Search and List Localities</h1>
    <alphabet-buttons
      @keypress="getLocalities($event)"
      ref="alphabetButtons"/>
  </div>
</template>
<script>

  import AlphabetButtons from './components/alphabet_buttons'
  import Spinner from '../../../components/spinner.vue'
  import CollectingEvent from './components/collectingEvent.vue'

  export default {
    components: {
      AlphabetButtons,
      Spinner,
      CollectingEvent
    },
    data() {
      return {
        isLoading: false,
        letter: '',
        selected: undefined,
      }
    },
    mounted() {
    },
    methods: {
    }
  }
</script>
