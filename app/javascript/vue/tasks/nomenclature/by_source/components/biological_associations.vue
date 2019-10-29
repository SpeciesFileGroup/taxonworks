<template>
  <div>
    <div class="flex-separate middle">
      <h2>Biological associations</h2>
      <button
        @click="summarize"
        :disabled="!sourceID"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="biological_association_cites_list"/>
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
        biological_association_cites_list: []
      }
    },
    watch: {
      sourceID() {
        this.getCites();
      }
    },
    methods: {
      getCites() {
        this.$http.get('/citations.json?citation_object_type=BiologicalAssociation&source_id=' + this.sourceID).then(response => {
          // build the tabular list, extracting the
          this.biological_association_cites_list = response.body;
          this.$emit("biological_association_cites", this.biological_association_cites_list)
        })
      },
      summarize() {
        this.$emit('summarize', { 
          type: 'biological_association_ids', 
          list: this.biological_association_cites_list 
        })
      }
    },
  }

</script>