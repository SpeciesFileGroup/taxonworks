<template>
  <div>
    <spinner-component
      v-if="showSpinner"/>
    <div class="flex-separate middle">
      <h2>Biological associations</h2>
      <button
        @click="summarize"
        :disabled="!sourceID || !biological_association_cites_list.length"
        class="button normal-input button-default">
        Summarize OTUs
      </button>
    </div>
    <table-component
      :list="biological_association_cites_list"/>
  </div>
</template>
<script>

import SpinnerComponent from 'components/spinner.vue'
import TableComponent from './tables/table.vue'
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

  data () {
    return {
      biological_association_cites_list: [],
      showSpinner: false
    }
  },

  watch: {
    sourceID () {
      this.getCites()
    }
  },

  methods: {
    getCites () {
      const params = {
        citation_object_type: 'BiologicalAssociation',
        source_id: this.sourceID
      }

      this.showSpinner = true
      Citation.where(params).then(response => {
        this.showSpinner = false
        this.biological_association_cites_list = response.body
      })
    },
    summarize () {
      this.$emit('summarize', {
        type: 'biological_association_ids',
        list: this.biological_association_cites_list
      })
    }
  },
}

</script>