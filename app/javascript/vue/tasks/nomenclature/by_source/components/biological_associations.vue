<template>
  <div>
    <h2>Biological Associations</h2>
    <table-component
        :list="biological_association_cites_list"/>
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
      sourceID: {
        type: String,
        default: "0"
      },
    },
    data() {
      return {
        biological_association_cites_list: []
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },
    methods: {
      getCites() {
        this.$http.get('/citations.json?citation_object_type=BiologicalAssociation&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.biological_association_cites_list = response.body;
          this.$emit("biological_association_cites", this.biological_association_cites_list)
        })
      }
    },
  }

</script>