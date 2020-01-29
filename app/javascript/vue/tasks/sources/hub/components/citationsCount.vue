<template>
  <a
    class="citation-count"
    :href="`/tasks/nomenclature/by_source?source_id=${sourceId}`">
    <span class="button-data circle-button btn-citation">
      <span class="circle-count button-default middle">{{ citations.length }} </span>
    </span>
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

<style lang="scss">
  .citation-count {
    position: relative;
  }

  .circle-count {
    right:-2px;
    bottom: -2px;
    justify-content: center;
    position: absolute;
    border-radius: 50%;
    display: flex;
    width: 12px;
    height: 12px;
    min-width: 12px;
    min-height: 12px;
    font-size: 8px;
    box-shadow: 0px 1px 2px 0px #EBEBEB;
    margin: 5px;
    cursor: pointer;
  }
</style>
