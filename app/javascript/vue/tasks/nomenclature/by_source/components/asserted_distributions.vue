<template>
  <div>
    <h2>Asserted Distributions</h2>
    <table>
      <tr v-for="item in asserted_distributions_cites_list">
        <td><input type="text" :value="item.pages"></td>
        <td v-html="item.citation_object.object_tag" />
        <td><radial-annotator :global-id="item.citation_object.global_id" /></td>
      </tr>
    </table>
  </div>
</template>
<script>
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import OtuRadial from '../../../../components/otu/otu.vue'
  export default {
    components: {
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
          // build the tabular list, extracting the
          this.asserted_distributions_cites_list = response.body;
          this.$emit("distribution_cites", this.asserted_distributions_cites_list)
        })
      }
    },
  }

</script>