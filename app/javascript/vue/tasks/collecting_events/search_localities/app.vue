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
  import Spinner from 'components/spinner.vue'

  export default {
    components: {
      AlphabetButtons,
      Spinner
    },
    data() {
      return {
        isLoasing: false,
        letter: '',
        dontKnowYet: '',
        localityList: []
      }
    },
    mounted() {
      let urlParams = new URLSearchParams(window.location.search)
      let letterParam = urlParams.get('letter').toUpperCase()

      if (/([A-Z])$/.test(letterParam) && letterParam.length == 1) {
        this.getLocalities(letterParam)
        this.$refs.alphabetButtons.setSelectedLetter(letterParam)
      }
    },
    methods: {
      getLocalities(letter) {
        this.isLoading = true
        this.$http.get(`/collecting_events.json?localities_start_with=${letter}&shape=${dontKnowYet}&area_id=${dontKnowYet}`).then(response => {
          this.localityList = response.body;
          this.isLoading = false
        })
      }
    }
  }
</script>
