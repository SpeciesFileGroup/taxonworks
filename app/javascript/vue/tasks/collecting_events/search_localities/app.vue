<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h1>Search and List Localities</h1>
    <h3>Geographic area</h3>
    <switch-component
      :options="Object.keys(smartGeographics)"
      v-model="view"
      :add-option="['search']"
      name="switch-geographic"/>
    <template v-if="smartGeographics[view]">
      <tag-item
        v-for="item in smartGeographics[view]"
        :item="item"
        display="name"
        @select="sendGeographic"
        :key="item.id"/>
    </template>
    <autocomplete
      v-else
      url="/geographic_areas/autocomplete"
      label="label_html"
      min="2"
      :clear-after="true"
      :autofocus="true"
      @getItem="sendGeographic"
      placeholder="Select a geographic area"
      param="term"/>
    <alphabet-buttons
      @keypress="getLocalities($event)"
      ref="alphabetButtons"/>
  </div>
</template>
<script>
  import AlphabetButtons from './components/alphabet_buttons'
  import Spinner from '../../../components/spinner.vue'
  import TagItem from '../../../components/annotator/components/shared/item_tag.vue'
  import SwitchComponent from '../../../components/annotator/components/shared/switch.vue'
  import Autocomplete from '../../../components/autocomplete.vue'

  export default {
    components: {
      AlphabetButtons,
      Spinner,
      TagItem,
      SwitchComponent,
      Autocomplete
    },
    data() {
      return {
        isLoading: false,
        letter: '',
        dontKnowYet: '',
        view: undefined,
        smartGeographics: [],
        selected: undefined,
        localityList: []
      }
    },
    mounted() {
      let urlParams = new URLSearchParams(window.location.search)
      let letterParam = urlParams.get('letter').toUpperCase()

      // if (/([A-Z])$/.test(letterParam) && letterParam.length == 1) {
      //   this.getLocalities(letterParam)
      //   this.$refs.alphabetButtons.setSelectedLetter(letterParam)
      // }
      this.getList(`/geographic_areas/select_options?target=CollectingEvent`).then(response => {
        let result = response.body
        Object.keys(result).forEach(key => (!result[key].length) && delete result[key]
    )
      this.smartGeographics = result
      this.view = this.firstTabWithData(result);
    })
    },
    methods: {
      sendGeographic(item) {
        this.selected = ''
        this.$emit('select', item.id)
      },
      getLocalities(letter, dontKnowYet) {
        this.isLoading = true
        this.$http.get(`/collecting_events.json?localities_start_with=${letter}&shape=${dontKnowYet}&area_id=${dontKnowYet}`).then(response => {
          this.localityList = response.body;
        this.isLoading = false
      })
      }
    }
  }
</script>
