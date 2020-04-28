<template>
  <button
    class="button normal-input button-default"
    :disabled="citation"
    type="button">
    Create citation
  </button>
</template>

<script>

import ajaxCall from 'components/ajaxCall'

export default {
  props: {
    sourceId: {
      type: [String, Number],
      required: true
    },
    globalId: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      citation: undefined
    }
  },
  methods: {
    createCitation () {
      ajaxCall('post', '/citations.json', {
        citation: {
          source_id: this.sourceId,
          global_id: this.globalId
        }
      }).then(response => {
        this.citation = response.body
        TW.workbench.alert.create('Citation was successfully created.', 'notice')
      })
    }
  }
}
</script>