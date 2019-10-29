<template>
  <div>
    <div class="flex-separate middle">
      <h2>Taxon names</h2>
      <button
        @click="summarize"
        :disabled="!sourceID"
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

  export default {
    components: {
      TaxonNamesTable
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
        taxon_names_list: []
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
        this.$http.get('/citations.json?verbose_object=true&citation_object_type=TaxonName&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_names_cites_list = response.body;
          this.$emit("taxon_names_cites", this.taxon_names_cites_list)
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