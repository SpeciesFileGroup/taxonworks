<template>
  <div>
    <div class="flex-separate middle">
      <h2>Asserted distributions</h2>
      <button
        @click="summarize"
        :disabled="!sourceID"
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

  export default {
    components: {
      TableComponent
    },
    props: {
      sourceID: {
        type: String,
        default: undefined
      },
    },
    data() {
      return {
        asserted_distributions_cites_list: []
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },
    methods: {
      getCites() {
        this.$http.get('/citations.json?citation_object_type=AssertedDistribution&source_id=' + this.sourceID).then(response => {
          this.asserted_distributions_cites_list = response.body;
          this.$emit("distribution_cites", this.asserted_distributions_cites_list)
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