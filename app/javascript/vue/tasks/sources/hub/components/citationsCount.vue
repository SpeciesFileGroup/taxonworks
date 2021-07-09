<template>
  <a
    class="citation-count button-data circle-button btn-citation"
    :href="`/tasks/nomenclature/by_source?source_id=${sourceId}`">
    <span class="circle-count button-default middle">{{ citations.length }} </span>
  </a>
</template>

<script>

import { Citation } from 'routes/endpoints'

export default {
  props: {
    sourceId: {
      type: [String, Number],
      required: true
    }
  },

  data() {
    return {
      citations: []
    }
  },

  mounted () {
    if (this.sourceId)
      this.loadCitations()
  },

  methods: {
    loadCitations () {
      Citation.where({ source_id: this.sourceId }).then(response => {
        this.citations = response.body
      })
    }
  }
}
</script>
