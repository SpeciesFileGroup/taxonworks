<template>
  <div>
    <h2>Biological Associations</h2>
    <table>
      <tr v-for="item in taxon_names_cites_list">
        <td><input type="text" :value="item.pages"></td>
        <td v-html="item.citation_object.object_tag" />
        <td><radial-annotator :global-id="item.global_id" /></td>
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
        type: String
      },
      sourceID: {
        type: String,
        default: "0"
      },
    },
    data() {
      return {
        taxon_names_cites_list: []
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
          this.taxon_names_cites_list = response.body;
        })
      }
    },
  }

</script>