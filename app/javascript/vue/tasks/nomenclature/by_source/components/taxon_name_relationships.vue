<template>
  <div>
    <h2>Taxon Name Relationships</h2>
    <table-component
        :list="taxon_relationship_cites_list"/>
  </div>
</template>
<script>
  import TableComponent from './tables/table.vue'
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import OtuRadial from '../../../../components/otu/otu.vue'
  export default {
    components: {
      TableComponent,
      RadialAnnotator,
      OtuRadial
    },
    props: {
      value: {
        type: String
      },
      sourceID: {
        type: String,
        default: '0'
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
        this.$http.get('/citations.json?citation_object_type=TaxonNameRelationship&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_relationship_cites_list = response.body;
          this.$emit("taxon_relationship_cites", this.taxon_relationship_cites_list)
        })
      }
    },
  }

</script>