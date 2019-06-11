<template>
  <div>
    <div v-if="keyId">
      <div
        v-if="!created"
        class="default_tag_widget circle-button btn-confidences btn-submit"
        @click="createConfidence()"
        title="Set default confidence"/>
      <div
        v-else
        class="default_tag_widget circle-button btn-confidences btn-delete"
        @click="deleteConfidence()"
        title="Remove default confidence"/>
    </div>
    <div
      v-else
      class="default_tag_widget circle-button btn-confidences btn-disabled"
      @click="deleteConfidence()"/>
  </div>
</template>

<script>
export default {
  props: {
    globalId: {
      type: String,
      required: true
    }
  },
  data: function () {
    return {
      confidenceItem: undefined,
      keyId: this.getDefault(),
      created: false,
    }
  },
  mounted() {
    this.alreadyCreated()
  },
  methods: {
    getDefault() {
      let defaultConfidence = document.querySelector('[data-pinboard-section="ConfidenceLevels"] [data-insert="true"]')
      return defaultConfidence ? defaultConfidence.getAttribute('data-pinboard-object-id') : undefined
    },
    alreadyCreated: function(element) {
      if(!this.keyId) return

      let params = {
        global_id: this.globalId,
        confidence_level_id: this.keyId
      }
      this.$http.get('/confidences/exists', { params: params }).then(response => {
        if(response.body) {
          this.created = true
          this.confidenceItem = response.body
        }
        else {
          this.created = false
        }
      })
    },
    createConfidence: function () {
      let ConfidenceItem = {
        confidence: {
          confidence_level_id: this.keyId,
          annotated_global_entity: this.globalId
        }
      }
      this.$http.post('/confidences', ConfidenceItem).then(response => {
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
      this.$http.delete(`/confidences/${this.confidenceItem.id}`, { confidence: confidence }).then(response => {
        this.created = false
        TW.workbench.alert.create('Confidence item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>