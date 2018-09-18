<template>
  <div>
    <h2>Asserted Distributions</h2>
    <table-component
      :list="asserted_distributions_cites_list"/>
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
        asserted_distributions_cites_list: []
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },
    methods: {
      getCites() {
        this.$http.get('/citations.json?citation_object_type=AssertedDistribution&source_id=' + this.sourceID).then(response => {
          this.asserted_distributions_cites_list = response.body;
          this.$emit("distribution_cites", this.asserted_distributions_cites_list)
        })
      }
    },
  }
</script>