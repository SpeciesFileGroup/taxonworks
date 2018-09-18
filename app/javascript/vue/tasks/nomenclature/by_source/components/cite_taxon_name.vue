<template>
  <div>
    <h2>Cite Taxon Name</h2>
    <smart-selector
      :options="tabs"
      name="citation"
      :add-option="moreOptions"
      v-model="view"/>
    <autocomplete
      v-if="view === 'Search'"
      url="/taxon_names/autocomplete"
      min="2"
      ref="autocomplete"
      param="term"
      placeholder="Search for a taxon"
      event-send="setTaxonforCite(item)"
      label="label"
      @getItem="foundTaxon = $event"
      :autofocus="true" />
    <button
      v-else
      v-for="item in showList[view]"
      :key="item.id"
      type="button"
      :class="{ 'button-default': !(selectedList.hasOwnProperty(item.id))}"
      class="button normal-input biocuration-toggle-button"
      @click="foundTaxon = item, createTaxonCite(item)"
      v-html="item.name"/>
    <button
      class="button normal-input button-default"
      @click="createTaxonCite()"
      :disabled="!foundTaxon.hasOwnProperty('id')"
      type="submit">Create Citation</button>
    <span>{{ errorMessage }}</span>
  </div>
</template>
<script>

  import SmartSelector from '../../../../components/switch.vue'
  import Autocomplete from '../../../../components/autocomplete.vue'

  export default {
    components: {
      SmartSelector,
      Autocomplete
    },
    props: {
      sourceID: {
        type: String,
        default: "0"
      }
    },
    data() {
      return {
        list: {},
        tabs: [],
        moreOptions: ['Search'],
        view: undefined,
        selectedList: {},
        newCitation: {},
        foundTaxon: {},
        errorMessage: ''
      }
    },
    methods: {
      setTaxonforCite() {
        this.foundTaxon = item;
      },
      createTaxonCite() {
        let params = {
          citation: {
            source_id: this.sourceID,
            citation_object_type: 'TaxonName',
            citation_object_id: this.foundTaxon.id
          }
        };
        this.$http.post(`/citations.json`, params).then(response => {
          this.$emit('foundTaxon', response.body);
          this.$refs.autocomplete.cleanInput()
        })
        .catch(error => {
          this.errorMessage = error.bodyText
        })
      }
    },
    computed: {
      showList() {
        return this.list
      }
    },
    mounted: function() {
      this.$http.get('/taxon_names/select_options').then(response => {
        this.tabs = Object.keys(response.body);
        this.list = response.body;
      })
    }
  }

</script>