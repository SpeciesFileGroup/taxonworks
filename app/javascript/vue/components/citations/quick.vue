<template>
  <div class="inline">
    <template v-if="pressed">
      <input
        type="text"
        v-model="pages"
        placeholder="Pages">
      <button
        class="button normal-input button-submit"
        :disabled="citation"
        @click="createCitation"
        type="button">
        Create
      </button>
    </template>
    <button
      v-else
    class="button normal-input button-default"
    :disabled="citation"
      @click="pressed = true"
    type="button">
      {{ label }}
  </button>
  </div>
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
      pages: undefined,
      label: 'Cite',
      pressed: false
    }
  },
  methods: {
    createCitation () {
      ajaxCall('post', '/citations.json', {
        citation: {
          source_id: this.sourceId,
          pages: this.pages,
          annotated_global_entity: this.globalId
        }
      }).then(response => {
        this.citation = response.body
        this.pressed = false
        this.label = 'Cited'
        TW.workbench.alert.create('Citation was successfully created.', 'notice')
      })
    }
  }
}
</script>