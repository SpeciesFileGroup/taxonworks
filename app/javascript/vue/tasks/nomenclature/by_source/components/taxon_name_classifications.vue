<template>
  <div>
    <div class="flex-separate middle">
      <h2>Taxon name classifications</h2>
      <button
        @click="summarize"
        :disabled="!sourceID"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="taxon_classification_cites_list"
    />
  </div>
</template>
<script>

import TableComponent from './tables/classification_table.vue'

  export default {
    components: {
      TableComponent,
    },
    props: {
      sourceID: {
        type: String,
        default: undefined
      },
    },
    data() {
      return {
        taxon_classification_cites_list: []
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },

    methods: {
      getCites() {
        this.$http.get('/citations.json?verbose_object=true&citation_object_type=TaxonNameClassification&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_classification_cites_list = response.body;
          this.$emit("taxon_classification_cites", this.taxon_classification_cites_list)
        })
      },
      summarize() {
        this.$emit('summarize', { 
          type: 'taxon_name_classification_ids', 
          list: this.taxon_classification_cites_list 
        })
      }
    },
  }
</script>