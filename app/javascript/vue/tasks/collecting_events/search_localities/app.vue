<template>
  <div>
    <h1>Search and List Localities</h1>
    <collecting-event
      @itemid="selectedItem=$event"
    />
  </div>
</template>
<script>
  import CollectingEvent from './components/collectingEvent.vue'
// TODO: add spinners, display count, refine display columns (more), (de)/persist lists
  export default {
    components: {
      CollectingEvent,
    },
    // data() {
    //   return {
    //     isLoading: false,
    //     letter: '',
    //     dontKnowYet: '',
    //     view: undefined,
    //     smartGeographics: [],
    //     selectedItem: undefined,
    //     localityList: []
    //   }
    // },
    // methods: {
    //   sendGeographic(item) {
    //     this.selected = '';
    //     this.$emit('select', item.id)
    //   },
    //   getLocalities(letter, dontKnowYet) {
    //     this.isLoading = true;
    //     this.$http.get(`/collecting_events.json?localities_start_with=${letter}&shape=${dontKnowYet}&area_id=${dontKnowYet}`).then(response => {
    //       this.localityList = response.body;
    //     this.isLoading = false
    //   })
    //   }
    // }
  }
</script>
