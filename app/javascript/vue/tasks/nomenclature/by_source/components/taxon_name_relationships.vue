<template>
  <div>
    <h2>Taxon name relationships</h2>
    <table-component
      :list="taxon_relationship_cites_list"/>
  </div>
</template>
<script>

  import TableComponent from './tables/relationship_table.vue'
  import RadialAnnotator from 'components/annotator/annotator.vue'
  import OtuRadial from 'components/otu/otu.vue'

  export default {
    components: {
      TableComponent,
      RadialAnnotator,
      OtuRadial
    },
    props: {
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
        this.$http.get('/citations.json?verbose_object=true&citation_object_type=TaxonNameRelationship&source_id=' + this.sourceID).then(response => {
          this.taxon_relationship_cites_list = response.body;
          this.$emit("taxon_relationship_cites", this.taxon_relationship_cites_list)
        })
      }
    },
  }
</script>