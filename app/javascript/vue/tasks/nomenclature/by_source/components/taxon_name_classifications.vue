<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle">
      <h2>Nomenclatural statuses</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !taxon_classification_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="taxon_classification_cites_list"
    />
  </div>
</template>
<script>

import TableComponent from './tables/classification_table.vue'
import SpinnerComponent from 'components/spinner.vue'
import { Citation } from 'routes/endpoints'

export default {
  components: {
    TableComponent,
    SpinnerComponent
  },

  props: {
    sourceID: {
      type: String,
      default: undefined
    }
  },

  emits: ['summarize'],

  data() {
    return {
      taxon_classification_cites_list: [],
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
      const params = {
        verbose_citation_object: true,
        citation_object_type: 'TaxonNameClassification',
        source_id: this.sourceID
      }

      this.showSpinner = true

      Citation.where(params).then(response => {
        this.taxon_classification_cites_list = response.body
        this.showSpinner = false
      })
    },
    summarize () {
      this.$emit('summarize', {
        type: 'taxon_name_classification_ids',
        list: this.taxon_classification_cites_list
      })
    }
  },
}
</script>