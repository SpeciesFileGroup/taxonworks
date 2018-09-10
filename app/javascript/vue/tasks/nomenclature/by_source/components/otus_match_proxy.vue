<template>
  <div>
    <h2>OTUs by match or proxy</h2>
    <otu-table-component :list="otu_names_cites_list"/>
  </div>
</template>
<script>
  // list items are to be annotatable OTUs
  // update list when changes occur in any of the citation list items
  //   mechanism for triggering reaction?

  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import OtuRadial from '../../../../components/otu/otu.vue'
  import OtuTableComponent from './tables/otu_table.vue'

  export default {
    components: {
      OtuTableComponent,
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
        otu_names_cites_list: [],
        otu_list: []
      }
    },
    watch: {
      sourceID() {
        // this.getCites();
        this.getSourceOtus();
      },
      updateOtus() {
        this.getSourceOtus();
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
      getSourceOtus() {
        return new Promise((resolve, reject) => {
          this.$http.get('/citations.json?citation_object_type=Otu&source_id=' + this.sourceID).then(response => {
            // citations currently until otu endpoint ready
            this.otu_list = response.body;
            resolve(response.body);
            let nameIDs = this.processNames(this.otu_list);
            let params = {taxon_name_ids:[], nameIDs};
            this.$http.get('/otus.json', params).then(response => {
              this.otu_names_cites_list = response.body;
            })
          });
        })
      },
      getOtus(citation_object_type) { return false;
      // iterate through all citation object types to rebuild this list
      //   this.otu_names_cites_list = [];
        this.getSourceOtus().then(response => {
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
      },
      processNames(list) {
        // list.forEach(getName)
        let taxonNames = [];
        for (item in list) {
          taxonNames.push(item.taxon_name_id);
        }
        return taxonNames;
      }
    },
  }

</script>