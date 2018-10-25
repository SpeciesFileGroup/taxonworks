<template>
  <div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <h2>OTUs by match or proxy</h2>
    <otu-table-component :list="otu_name_list"/>
  </div>
</template>
<script>
  // list items are annotatable OTUs
  // update list when changes occur in any of the citation list items
  import RadialAnnotator from 'components/annotator/annotator.vue'
  import OtuRadial from 'components/otu/otu.vue'
  import OtuTableComponent from './tables/otu_table.vue'
  import Spinner from 'components/spinner.vue'

  export default {
    components: {
      OtuTableComponent,
      RadialAnnotator,
      OtuRadial,
      Spinner
    },
    props: {
      sourceID: {
        type: String,
        default: "0",
      },
      otu_names_cites: {
        type: Array,
        default: () => { return [] }
      },
      taxon_names_cites: {
        type: Array,
        default: () => { return [] }
      },
      taxon_relationship_cites: {
        type: Array,
        default: () => { return [] }
      },
      taxon_classification_cites: {
        type: Array,
        default: () => { return [] }
      },
      biological_association_cites: {
        type: Array,
        default: () => { return [] }
      },
      distribution_cites: {
        type: Array,
        default: () => { return [] }
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
        processingList: false,
        isLoading: false,
        lastRun: undefined
      }
    },
    watch: {
      sourceID() {
        this.getSourceOtus()
      },
      otu_names_cites() {
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
        let promises = [];
        let runTime = Date.now()
        this.lastRun = runTime
        this.otu_name_list = [];
        this.isLoading = true

        promises.push(this.processType(this.getIdsList(this.otu_names_cites), 'otu_ids'));
        promises.push(this.processType(this.getIdsList(this.taxon_names_cites), 'taxon_name_ids'));
        promises.push(this.processType(this.getIdsList(this.taxon_relationship_cites), 'taxon_name_relationship_ids'));
        promises.push(this.processType(this.getIdsList(this.taxon_classification_cites), 'taxon_name_classification_ids'));
        promises.push(this.processType(this.getIdsList(this.biological_association_cites), 'biological_association_ids'));
        promises.push(this.processType(this.getIdsList(this.distribution_cites), 'asserted_distribution_ids'));

        Promise.all(promises).then(lists => {
          if(this.lastRun == runTime) {
            this.otu_id_list = [].concat.apply([], lists)
            this.isLoading = false
          }
        })
      },
      addOtu(otu) {
        if((this.otu_name_list.findIndex(item => {return item.id == otu.id})) < 0) {
          this.otu_name_list.push(otu)
        }
      },
      getIdsList(list) {
        return list.map((item) => { return item.citation_object_id })
      },
      processType(list, type) {
        return new Promise((resolve, reject) => {
          let params = {
            [type]: list
          };
          this.$http.get('/otus.json', { params: params }).then(response => {
            response.body.forEach(this.addOtu);
            resolve(response.body)
          })
        })
      }
    },
  }
</script>