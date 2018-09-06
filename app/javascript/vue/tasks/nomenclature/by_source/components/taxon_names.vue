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
  import TableComponent from './table/table.vue'

  export default {
    components: {
      RadialAnnotator,
      TableComponent,
      OtuRadial
    },
    props: {
      value: {
        type: String
      },
      sourceID: {
        type: String,
        default: "0" //window.location.href.split('/')[1]
      },
      newTaxon: {
        type: Object,
        default: {}
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
// TODO: method for receiving new citation from cite_taxon_name (addToList( ?))
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
    // mounted: function() {
    //   // let pieces = window.location.href.split('/')
    //   // this.source_id = pieces[pieces.length - 1];
    //
    // }
  }

</script>