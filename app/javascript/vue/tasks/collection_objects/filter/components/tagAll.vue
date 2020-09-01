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

import { CreateTags } from '../request/resources'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    SpinnerComponent
  },
  props: {
    ids: {
      type: Array,
      default: () => { return [] }
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
  mounted () {
    let that = this
    document.addEventListener('pinboard:insert', function (event) {
      if (event.detail.type == 'ControlledVocabularyTerm') { 
        that.keywordId = that.getDefault()
      }
    })
  },
  methods: {
    getDefault() {
      let defaultTag = document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')
      return defaultTag ? defaultTag.getAttribute('data-pinboard-object-id') : undefined
    },
    tagAll() {
      this.showSpinner = true
      CreateTags(this.keywordId, this.ids, this.type).then(response => {
        this.showSpinner = false
        TW.workbench.alert.create('Tags was successfully created', 'notice')
      })
    }
  }
}
</script>