<template>
  <div>
    <h2>OTU Names</h2>
    <table-component
        :list="otu_names_cites_list"/>
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
      value: {
        type: String
      },
      sourceID: {
        type: String,
        default: "0"
      },
      newTaxon: {
        type: Object,
        default: {}
      }
    },
    data() {
      return {
        otu_names_cites_list: []
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
        this.$http.get('/citations.json?citation_object_type=Otu&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.otu_names_cites_list = response.body;
          this.$emit("otu_names_cites", this.otu_names_cites_list)
        })
      },
      addToList(citation) {
        this.otu_names_cites_list.push(citation);
      }
    },
  }
</script>