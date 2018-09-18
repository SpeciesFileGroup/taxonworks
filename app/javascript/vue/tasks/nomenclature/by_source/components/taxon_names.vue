<template>
  <div>
    <h2>Taxon Names</h2>
    <table-component 
      :list="taxon_names_cites_list"/>
  </div>
</template>
<script>

  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import OtuRadial from '../../../../components/otu/otu.vue'
  import TableComponent from './tables/table.vue'

  export default {
    components: {
      RadialAnnotator,
      TableComponent,
      OtuRadial
    },
    props: {
      sourceID: {
        type: String,
        default: "0"
      },
      newTaxon: {
        type: Object,
        default: () => { return {} }
      }
    },
    data() {
      return {
        taxon_names_cites_list: []
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
        this.$http.get('/citations.json?citation_object_type=TaxonName&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_names_cites_list = response.body;
          this.$emit("taxon_names_cites", this.taxon_names_cites_list)
        })
      },
      addToList(citation) {
        this.taxon_names_cites_list.push(citation);
      }
    },
  }
</script>