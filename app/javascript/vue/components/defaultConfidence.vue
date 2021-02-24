<template>
  <div>
    <div v-if="keyId">
      <tippy-component
        v-if="!created"
        animation="scale"
        placement="bottom"
        size="small"
        :inertia="true"
        :arrow="true"
        :content="`<p>Create confidence: ${getDefaultElement().firstChild.firstChild.textContent}.${confidenceCount ? `<br>Used already  on ${confidenceCount} ${confidenceCount > 200 ? 'or more' : '' } objects</p>` : ''}`">
        <template v-slot:trigger>
          <div
            class="default_tag_widget circle-button btn-confidences btn-submit"
            @click="createConfidence()"/>
        </template>
      </tippy-component>

      <tippy-component
        v-else
        animation="scale"
        placement="bottom"
        size="small"
        :inertia="true"
        :arrow="true"
        :content="`<p>Remove confidence: ${getDefaultElement().firstChild.firstChild.textContent}.${confidenceCount ? `<br>Used already on ${confidenceCount} ${confidenceCount > 200 ? 'or more' : '' } objects</p>` : ''}`">
        <template v-slot:trigger>
          <div
            class="default_tag_widget circle-button btn-confidences btn-delete"
            @click="deleteConfidence()"
            title="Remove default confidence"/>
        </template>
      </tippy-component>
    </div>
    <div
      v-else
      class="default_tag_widget circle-button btn-confidences btn-disabled"/>
  </div>
</template>

<script>

import { TippyComponent } from 'vue-tippy'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    TippyComponent
  },
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
  data: function () {
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
      let defaultConfidence = this.getDefaultElement()
      return defaultConfidence ? defaultConfidence.getAttribute('data-pinboard-object-id') : undefined
    },
    getDefaultElement () {
      return document.querySelector('[data-pinboard-section="ConfidenceLevels"] [data-insert="true"]')
    },
    alreadyCreated: function(element) {
      if(!this.keyId) return

      let params = {
        global_id: this.globalId,
        confidence_level_id: this.keyId
      }
      AjaxCall('get', '/confidences/exists', { params: params }).then(response => {
        if(response.body) {
          this.created = true
          this.confidenceItem = response.body
        }
        else {
          this.created = false
        }
      })
    },
    getCount () {
      if(!this.keyId) return
      const params = {
        confidence_level_id: [this.keyId],
        per: 100
      }
      AjaxCall('get', '/confidences', { params: params }).then(response => {
        this.confidenceCount = response.body.length
      })
    },
    createConfidence: function () {
      let ConfidenceItem = {
        confidence: {
          confidence_level_id: this.keyId,
          annotated_global_entity: this.globalId
        }
      }
      AjaxCall('post', '/confidences', ConfidenceItem).then(response => {
        this.confidenceItem = response.body
        this.created = true
        TW.workbench.alert.create('Confidence item was successfully created.', 'notice')
      })
    },
    deleteConfidence: function () {
			let confidence = {
				annotated_global_entity: this.globalId,
				_destroy: true
			}
      AjaxCall('delete', `/confidences/${this.confidenceItem.id}`, { confidence: confidence }).then(response => {
        this.created = false
        TW.workbench.alert.create('Confidence item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>