<template>
  <div>
    <h2>Taxon names</h2>
    <taxon-names-table
        :list="taxon_names_cites_list"
        :names="taxon_names_list"/>
  </div>
</template>
<script>

  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import OtuRadial from '../../../../components/otu/otu.vue'
  import TaxonNamesTable from './tables/taxon_names_table.vue'

  export default {
    components: {
      RadialAnnotator,
      TaxonNamesTable,
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
        this.$http.get('/citations.json?citation_object_type=TaxonName&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_names_cites_list = response.body;
        });
        let citation;
        for (citation in this.taxon_names_cites_list) {
          this.getNameData(this.taxon_names_cites_list[citation].id)
        }
        this.$emit("taxon_names_cites", this.taxon_names_cites_list)
      },
      addToList(citation) {
        this.taxon_names_cites_list.push(citation);
        this.$emit("taxon_names_cites", this.taxon_names_cites_list)
      },
      getNameData(id) {
        // let id = this.taxon_names_cites_list[citation].id
        this.$http.get('/taxon_names/' + id + '.json').then(response => {
          this.taxon_names_list.push(response.body)
        });
      }
    },
  }
</script>