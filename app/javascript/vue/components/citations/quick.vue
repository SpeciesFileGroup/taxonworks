<template>
  <button
    class="button normal-input button-default"
    :disabled="citation"
    @click="createCitation"
    type="button">
    {{ label }}
  </button>
</template>

<script>

import ajaxCall from 'helpers/ajaxCall'

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
      citation: undefined,
      label: 'Cite'
    }
  },
  methods: {
    createCitation () {
      ajaxCall('post', '/citations.json', {
        citation: {
          source_id: this.sourceId,
          annotated_global_entity: this.globalId
        }
      }).then(response => {
        this.citation = response.body
        this.label = 'Created'
        TW.workbench.alert.create('Citation was successfully created.', 'notice')
      })
    }
  }
}
</script>