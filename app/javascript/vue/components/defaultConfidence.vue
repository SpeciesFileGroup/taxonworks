<template>
  <div v-if="keyId">
    <tippy
      v-if="!created"
      animation="scale"
      placement="bottom"
      size="small"
      :inertia="true"
      :arrow="true"
      :content="`<p>Create confidence: ${getDefaultElement().firstChild.firstChild.textContent}.${confidenceCount ? `<br>Used already  on ${confidenceCount} ${confidenceCount > 200 ? 'or more' : '' } objects</p>` : ''}`">
      <div
        class="default_tag_widget circle-button btn-confidences btn-submit"
        @click="createConfidence()"/>
    </tippy>

    <tippy
      v-else
      animation="scale"
      placement="bottom"
      size="small"
      :inertia="true"
      :arrow="true"
      :content="`<p>Remove confidence: ${getDefaultElement().firstChild.firstChild.textContent}.${confidenceCount ? `<br>Used already on ${confidenceCount} ${confidenceCount > 200 ? 'or more' : '' } objects</p>` : ''}`">
      <div
        class="default_tag_widget circle-button btn-confidences btn-delete"
        @click="deleteConfidence()"
        title="Remove default confidence"/>
    </tippy>
  </div>
  <div
    v-else
    class="default_tag_widget circle-button btn-confidences btn-disabled"/>
</template>

<script>

import { Tippy } from 'vue-tippy'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: { Tippy },

  props: {
    globalId: {
      type: String,
      required: true
    },

    tooltip: {
      type: Boolean,
      default: true
    },

    count: {
      type: [Number, String],
      default: undefined
    }
  },

  data () {
    return {
      confidenceItem: undefined,
      keyId: this.getDefault(),
      created: false,
      confidenceCount: undefined
    }
  },

  watch: {
    count: {
      handler (newVal) {
        this.confidenceCount = newVal
      },
      immediate: true
    }
  },

  mounted () {
    this.alreadyCreated()
    document.addEventListener('pinboard:insert', (event) => {
      const details = event.detail
      if (details.type === 'ControlledVocabularyTerm') {
        this.keyId = this.getDefault()
        this.getCount()
        this.alreadyCreated()
      }
    })
  },

  methods: {
    getDefault () {
      const defaultConfidence = this.getDefaultElement()
      return defaultConfidence ? defaultConfidence.getAttribute('data-pinboard-object-id') : undefined
    },

    getDefaultElement () {
      return document.querySelector('[data-pinboard-section="ConfidenceLevels"] [data-insert="true"]')
    },

    alreadyCreated (element) {
      if (!this.keyId) return

      const params = {
        global_id: this.globalId,
        confidence_level_id: this.keyId
      }
      AjaxCall('get', '/confidences/exists', { params }).then(response => {
        if (response.body) {
          this.created = true
          this.confidenceItem = response.body
        }
        else {
          this.created = false
        }
      })
    },

    getCount () {
      if (!this.keyId) return

      const params = {
        confidence_level_id: [this.keyId],
        per: 100
      }

      AjaxCall('get', '/confidences', { params: params }).then(response => {
        this.confidenceCount = response.body.length
      })
    },

    createConfidence () {
      const confidence = {
        confidence_level_id: this.keyId,
        annotated_global_entity: this.globalId
      }

      AjaxCall('post', '/confidences', { confidence }).then(response => {
        this.confidenceItem = response.body
        this.created = true
        TW.workbench.alert.create('Confidence item was successfully created.', 'notice')
      })
    },

    deleteConfidence () {
      const confidence = {
        annotated_global_entity: this.globalId,
        _destroy: true
      }

      AjaxCall('delete', `/confidences/${this.confidenceItem.id}`, { confidence }).then(() => {
        this.created = false
        TW.workbench.alert.create('Confidence item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>
