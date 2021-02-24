<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle">
      <h2>Taxon names</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !taxon_names_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <taxon-names-table
        :list="taxon_names_cites_list"
        :names="taxon_names_list"/>
  </div>
</template>
<script>

  import TaxonNamesTable from './tables/taxon_names_table.vue'
  import SpinnerComponent from 'components/spinner.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      TaxonNamesTable,
      SpinnerComponent
    },
    props: {
      sourceID: {
        type: String,
        default: undefined
      },
      newTaxon: {
        type: Object,
        default: () => { return {} }
      }
    },
    data() {
      return {
        taxon_names_cites_list: [],
        taxon_names_list: [],
        showSpinner: false
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      },
      newTaxon() {
        this.addToList(this.newTaxon)
      }
    },
    methods: {
      getCites() {
        this.showSpinner = true
        AjaxCall('get', '/citations.json?verbose_object=true&citation_object_type=TaxonName&source_id=' + this.sourceID).then(response => {
          this.taxon_names_cites_list = response.body;
          this.showSpinner = false
        });
      },
      addToList(citation) {
        this.taxon_names_cites_list.push(citation);
        this.$emit("taxon_names_cites", this.taxon_names_cites_list)
      },
      summarize() {
        this.$emit('summarize', { 
          type: 'taxon_name_ids', 
          list: this.taxon_names_cites_list 
        })
      }
    },
  }
</script>