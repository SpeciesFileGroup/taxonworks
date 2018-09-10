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
      getSourceOtus() {
        return new Promise((resolve, reject) => {
          this.$http.get('/citations.json?citation_object_type=Otu&source_id=' + this.sourceID).then(response => {
            // citations currently until otu endpoint ready
            this.otu_list = response.body;
            // let nameIDs = this.processNames(this.otu_list);
            let params = { otu_ids: this.otu_list.map((item) => { return item.citation_object_id }) };
            console.log(params);
            this.$http.get('/otus.json', { params: params }).then(response => {
              this.otu_names_cites_list = response.body;
              resolve(response.body);
            })
          });
        })
      },
      getOtus(citation_object_type) {
      // iterate through all citation object types to rebuild this list
      //   this.otu_names_cites_list = [];
        this.getSourceOtus().then(response => {
          this.processType(this.taxon_names_cites, 'taxon_name_ids'); // this.taxon_names_cites.forEach(this.addCite);
          this.processType(this.taxon_relationship_cites, 'taxon_name_relationships'); // this.taxon_relationship_cites.forEach(this.addCite);
          this.processType(this.taxon_classification_cites, 'taxon_name_classifications'); // this.taxon_classification_cites.forEach(this.addCite);
          // this.processType(this.biological_association_cites, 'biological_association_cites'); // this.biological_association_cites.forEach(this.addCite);
          this.processType(this.distribution_cites, 'asserted_distributions'); // this.distribution_cites.forEach(this.addCite);
          this.$emit("updateEnd", false);
        });
      },
      addCite(cite) {
        this.otu_names_cites_list.push(cite)
      },
      processType(list, type) {
        // list.forEach(getName)
        let idList = list.map((item) => { return item.citation_object_id });
        let params = {};
        switch (type) {
          case 'taxon_name_ids':
          {params = { taxon_name_ids: idList};}
            break;
          case 'taxon_name_relationships':
          {params = { taxon_name_ids: idList};}
            break;
          case 'taxon_name_classifications':
          {params = { taxon_name_ids: idList};}
            break;
          case 'biological_associations':
          { params = { biological_associations: idList};}
            break;
          case 'asserted_distributions':
          { params = { otus: idList};}
            break;
        }
        this.$http.get('/otus.json', { params: params }).then(response => {
          this.otu_list = response.body;
          this.otu_list.forEach(this.addCite);
          // resolve(response);
        }
        )
        // let taxonNames = [];
        // for (item in list) {
        //   if (item.citation_object_id) {
        //     taxonNames.push(item.citation_object_id);
        //   }
        // }
        // return taxonNames;
      }
    },
  }

</script>