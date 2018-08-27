<template>
  <div>
    <h3>Cite Taxon Name</h3>
    <smart-selector
        :options="tabs"
        name="citation"
        :select-options-url="/taxon_names/select_options"
        :add-option="moreOptions"
        v-model="view"/>
    <input type="text"
           placeholder="search for a taxon" />
  </div>
</template>
<script>
  import smartSelector from './smartSelector.vue'
  export default {
    components: {
      smartSelector
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
        tabs: [],
        moreOptions: [],
        view: undefined,
        selectedList: {}
      }
    },
    mounted: function() {
      this.$http.get('/taxon_names/select_options').then(response =>
    {
      this.tabs = response.body;
    })
    }
  }

</script>