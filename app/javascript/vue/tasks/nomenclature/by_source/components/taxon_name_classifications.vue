<template>
  <div>
    <h3>Taxon Name Classifications</h3>
    <table>
      <tr v-for="item in taxon_names_cites_list">
        <td><input type="text" :value="item.pages"></td>
        <td v-html="item.citation_object_tag" />
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

      },
      source_id: {
        type: Number,
        default: 0
      },
    },
    data() {
      return {
        taxon_names_cites_list: []
      }
    },
    mounted: function() {
      let pieces = window.location.href.split('/')
      this.sourceID = pieces[pieces.length - 1];

      this.$http.get('/citations?citation_object_type=TaxonName&source_id=' + this.source_id).then(response => {
        // build the tabular list, extracting the
        this.taxon_names_cites_list = response.body;
      })
    }
  }

</script>