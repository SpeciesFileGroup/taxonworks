<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle"> 
      <h2>Taxon name relationships</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !taxon_relationship_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="taxon_relationship_cites_list"/>
  </div>
</template>
<script>

  import TableComponent from './tables/relationship_table.vue'
  import SpinnerComponent from 'components/spinner.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    components: {
      TableComponent,
      SpinnerComponent
    },
    props: {
      sourceID: {
        type: String,
        default: undefined
      },
    },
    data() {
      return {
        taxon_relationship_cites_list: [],
        showSpinner: false
      }
    },
    watch: {
      sourceID() {
        this.getCites()
      }
    },
    methods: {
      getCites() {
        this.showSpinner = true
        AjaxCall('get', '/citations.json?verbose_object=true&citation_object_type=TaxonNameRelationship&source_id=' + this.sourceID).then(response => {
          this.taxon_relationship_cites_list = response.body;
          this.showSpinner = false
        })
      },
      summarize() {
        this.$emit('summarize', { 
          type: 'taxon_name_relationship_ids', 
          list: this.taxon_relationship_cites_list 
        })
      }
    },
  }
</script>