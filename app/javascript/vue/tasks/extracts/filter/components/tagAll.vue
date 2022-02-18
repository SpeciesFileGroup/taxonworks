<template>
  <div>
    <spinner-component 
      v-if="showSpinner"
      :full-screen="true"
      legend="Creating tags..."/>
    <button
      class="button normal-input button-submit"
      type="button"
      @click="tagAll"
      :disabled="!keywordId || !ids.length">
      Tag
    </button>
  </div>
</template>

<script>

import { Tag } from 'routes/endpoints'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    SpinnerComponent
  },

  props: {
    ids: {
      type: Array,
      default: () => []
    },
    type: {
      type: String,
      required: true
    }
  },

  data () {
    return {
      keywordId: this.getDefault(),
      showSpinner: false
    }
  },

  created () {
    document.addEventListener('pinboard:insert', (event) => {
      if (event.detail.type === 'ControlledVocabularyTerm') {
        this.keywordId = this.getDefault()
      }
    })
  },

  methods: {
    getDefault () {
      const defaultTag = document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')
      return defaultTag ? defaultTag.getAttribute('data-pinboard-object-id') : undefined
    },

    tagAll () {
      this.showSpinner = true
      Tag.createBatch({
        object_type: this.type,
        keyword_id: this.keywordId,
        object_ids: this.ids
      }).then(() => {
        this.showSpinner = false
        TW.workbench.alert.create('Tags was successfully created', 'notice')
      })
    }
  }
}
</script>