<template>
  <div>
    <h3>Cite Taxon Name</h3>
    <smart-selector
        :options="tabs"
        name="citation"
        :add-option="moreOptions"
        v-model="view"/>
    <autocomplete
      url="/otus/autocomplete"
      min="2"
      param="term"
      placeholder="Search for a taxon"
      event-send="otupicker"
      label="label"
      :autofocus="true" />
  </div>
</template>
<script>
  import SmartSelector from './smartSelector.vue'
  import Autocomplete from '../../../../components/autocomplete.vue'
  export default {
    components: {
      SmartSelector,
      Autocomplete
    },
    props: {
      // selectOptionsUrl: {
      //   type: String
      // },
      // allSelectOptionUrl: {
      //   type: String
      // },
      value: {
        type: Object,
      },
    },
    data() {
      return {
        list: {},
        tabs: [],//,[],
        moreOptions: [],
        view: undefined,
        selectedList: {}
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