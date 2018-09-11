<template>
  <div>
    <h2>OTUs by match or proxy</h2>
    <otu-table-component :list="otu_name_list"/>
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
        otu_name_list: [],
        otu_id_list: [],
        processingList: false
      }
    },
    watch: {
      sourceID() {
        this.getSourceOtus()
      },
      taxon_names_cites() {
        this.getSourceOtus()
      },
      taxon_relationship_cites() {
        this.getSourceOtus()
      },
      taxon_classification_cites() {
        this.getSourceOtus()
      },
      biological_association_cites() {
        this.getSourceOtus()
      },
      distribution_cites() {
        this.getSourceOtus()
      }
    },
    methods: {
      getSourceOtus() {
        this.$http.get('/citations.json?citation_object_type=Otu&source_id=' + this.sourceID).then(response => {
            // citations currently until otu endpoint ready
          this.otu_id_list = response.body;
          let params = { otu_ids: this.getIdsList(this.otu_id_list) };
          this.$http.get('/otus.json', { params: params }).then(response => {
            let promises = []
            this.otu_name_list = response.body;

            promises.push(this.processType(this.getIdsList(this.taxon_names_cites), 'taxon_name_ids'))
            promises.push(this.processType(this.getIdsList(this.taxon_relationship_cites), 'taxon_name_relationship_ids'))
            promises.push(this.processType(this.getIdsList(this.taxon_classification_cites), 'taxon_name_classification_ids'))
            promises.push(this.processType(this.getIdsList(this.biological_association_cites), 'biological_association_ids'))
            promises.push(this.processType(this.getIdsList(this.distribution_cites), 'asserted_distribution_ids'))

            Promise.all(promises).then(lists => {
              this.otu_id_list = [].concat.apply([], lists)
            })
          })
        })
      },
      addOtu(cite) {
        this.otu_name_list.push(cite)
      },
      getIdsList(list) {
        return list.map((item) => { return item.citation_object_id })
      },
      processType(list, type) {
        return new Promise((resolve, reject) => {
          let params = {
            [type]: list
          }
          this.$http.get('/otus.json', { params: params }).then(response => {
            response.body.forEach(this.addOtu);
            resolve(response.body)
          })          
        })
      }
    },
  }

</script>