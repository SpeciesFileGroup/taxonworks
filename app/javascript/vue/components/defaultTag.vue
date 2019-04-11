
<template>
  <div v-if="keyId">
    <div
      v-if="!created"
      class="default_tag_widget circle-button btn-tag-add"
      @click="createTag()"/>
    <div
      v-else
      class="default_tag_widget circle-button btn-tag-delete"
      @click="deleteTag()"/>
  </div>
</template>

<script>
export default {
  props: {
    globalId: {
      type: String
    }
  },
  data: function () {
    return {
      tagItem: undefined,
      keyId: this.getDefault(),
      created: false,
    }
  },
  mounted() {
    this.alreadyTagged()
  },
  methods: {
    getDefault() {
      return document.querySelector('[data-pinboard-section="ControlledVocabularyTerms"] [data-insert="true"]').getAttribute('data-pinboard-object-id')
    },
    alreadyTagged: function(element) {
      if(!this.keyId) return

      let params = {
        global_id: this.globalId,
        keyword_id: this.keyId
      }
      this.$http.get('/tags/exists', { params: params }).then(response => {
        if(response.body) {
          this.created = true
        }
        else {
          this.created = false
        }
      })
    },
    createTag: function () {
      let tagItem = {
        tag: {
          keyword_id: this.keyId,
          annotated_global_entity: this.globalId
        }
      }
      this.$http.post('/tags', tagItem).then(response => {
        this.tagItem = response.body
        TW.workbench.alert.create('Tag item was successfully created.', 'notice')
      })
    },
    deleteTag: function () {
			let tag = {
				annotated_global_entity: this.globalId,
				_destroy: true
			}
      this.$http.delete(`/tags/${this.pin.id}`, { tag: tag }).then(response => {
        TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>