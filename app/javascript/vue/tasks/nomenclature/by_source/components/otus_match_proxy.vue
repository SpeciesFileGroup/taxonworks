<template>
  <div>
    <h2>OTUs by match or proxy</h2>
    <table>
      <tr><th>pages</th><th>otu</th><th>radial</th><th>otu</th></tr>
      <tr v-for="item in taxon_names_cites_list">
        <td><input type="text" :value="item.pages"></td>
        <td v-html="item.citation_object.object_tag" />
        <td><radial-annotator :global-id="item.citation_object.global_id" /></td>
        <td><otu-radial :taxon-id="item.citation_object_id" :redirect="false" /></td>
      </tr>
    </table>
  </div>
</template>
<script>
  // list items are to be annotatable OTUs
  // update list when changes occur in any of the citation list items
  //   mechanism for triggering reaction?

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
        this.$http.get('/citations.json?citation_object_type=TaxonName&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.taxon_names_cites_list = response.body;
        })
      }
    },
  }

</script>