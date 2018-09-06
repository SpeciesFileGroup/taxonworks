<template>
  <div>
    <h2>OTUs by match or proxy</h2>
    <table>
      <tr><th>pages</th><th>otu</th><th>radial</th><th>otu</th></tr>
      <tr v-for="item in otu_names_cites_list">
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
        default: "0",
      },
      taxon_names_cites: {
        type: Array,
        default: [],
      },
      taxon_relationship_cites: {
        type: Array,
        default: [],
      },
      taxon_classification_cites: {
        type: Array,
        default: [],
      },
      biological_association_cites: {
        type: Array,
        default: [],
      },
      distribution_cites: {
        type: Array,
        default: [],
      },
      updateOtus: {
        type: Boolean,
        default: false
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
      updateOtus() {
        this.getOtus();
      }
    },

    methods: {
      getCites() {
        return new Promise((resolve, reject) => {
          this.$http.get('/citations.json?citation_object_type=Otu&source_id=' + this.sourceID).then(response => {
            // citations currently until otu endpoint ready
            this.otu_names_cites_list = response.body;
            resolve(response.body);
          })
        })
      },
      getOtus(citation_object_type) {
      // iterate through all citation object types to rebuild this list
      //   this.otu_names_cites_list = [];
        this.getCites().then(() => {
          this.taxon_names_cites.forEach(this.addCite);
          this.taxon_relationship_cites.forEach(this.addCite);
          this.taxon_classification_cites.forEach(this.addCite);
          this.biological_association_cites.forEach(this.addCite);
          this.distribution_cites.forEach(this.addCite);
          this.$emit("updateEnd", false);
        });
      },
      addCite(cite) {
        this.otu_names_cites_list.push(cite)
      }
    },
  }

</script>