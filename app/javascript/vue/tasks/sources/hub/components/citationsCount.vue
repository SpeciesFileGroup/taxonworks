<template>
  <a
    class="citation-count button-data circle-button btn-citation"
    :href="`/tasks/nomenclature/by_source?source_id=${sourceId}`">
    <span class="circle-count button-default middle">{{ citations.length }} </span>
  </a>
</template>

<script>

import { GetCitationsFromSourceID } from '../request/resources.js'

export default {
  props: {
    sourceId: {
      type: [String, Number],
      required: true
    },
  },
  data() {
    return {
      citations: []
    }
  },
  mounted() {
    if(this.sourceId)
      this.loadCitations()
  },
  methods: {
    loadCitations() {
      GetCitationsFromSourceID(this.sourceId).then(response => {
        this.citations = response.body
      })
    }
  }
}
</script>
