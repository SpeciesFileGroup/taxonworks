<template>
  <div>
    <h2>Taxon Name Classifications</h2>
    <table-component
      :list="taxon_classification_cites_list"
    />
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

      },
      sourceID: {
        type: String,
        default: "0"
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
        this.$http.get('/citations.json?citation_object_type=TaxonNameClassification&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_classification_cites_list = response.body;
          this.$emit("taxon_classification_cites", this.taxon_classification_cites_list)
        })
      },
    },
  }

</script>