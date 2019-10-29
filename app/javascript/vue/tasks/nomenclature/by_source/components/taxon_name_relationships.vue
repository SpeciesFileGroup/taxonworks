<template>
  <div>
    <div class="flex-separate middle"> 
      <h2>Taxon name relationships</h2>
      <button
        @click="summarize"
        :disabled="!sourceID"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="taxon_relationship_cites_list"/>
  </div>
</template>
<script>

  import TableComponent from './tables/relationship_table.vue'

  export default {
    components: {
      TableComponent
    },
    props: {
      sourceID: {
        type: String,
        default: undefined
      },
    },
    data() {
      return {
        taxon_relationship_cites_list: []
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },
    methods: {
      getCites() {
        this.$http.get('/citations.json?verbose_object=true&citation_object_type=TaxonNameRelationship&source_id=' + this.sourceID).then(response => {
          this.taxon_relationship_cites_list = response.body;
          this.$emit("taxon_relationship_cites", this.taxon_relationship_cites_list)
        })
      },
      summarize() {
        this.$emit('summarize', { 
          type: 'taxon_name_relationship_ids', 
          list: this.taxon_relationship_cites_list 
        })
      }
    },
  }
</script>