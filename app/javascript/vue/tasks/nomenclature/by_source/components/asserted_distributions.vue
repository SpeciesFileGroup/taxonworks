<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle">
      <h2>Asserted distributions</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !asserted_distributions_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="asserted_distributions_cites_list"/>
  </div>
</template>
<script>

import TableComponent from './tables/table.vue'
import SpinnerComponent from 'components/spinner.vue'

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
        asserted_distributions_cites_list: [],
        showSpinner: false
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },
    methods: {
      getCites() {
        this.showSpinner = true
        this.$http.get('/citations.json?citation_object_type=AssertedDistribution&source_id=' + this.sourceID).then(response => {
          this.asserted_distributions_cites_list = response.body;
          this.showSpinner = false
        })
      },
      summarize() {
        this.$emit('summarize', { 
          type: 'asserted_distribution_ids', 
          list: this.asserted_distributions_cites_list 
        })
      }
    },
  }
</script>