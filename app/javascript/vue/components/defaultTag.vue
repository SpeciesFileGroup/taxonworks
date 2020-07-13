
<template>
  <div v-if="keyId">
    <tippy-component
      v-if="!created"
      animation="scale"
      placement="bottom"
      size="small"
      :inertia="true"
      :arrow="true"
      :content="`<p>Create tag: ${getDefaultElement().firstChild.firstChild.textContent}.${showCount ? `<br>Used already on ${countTag} ${countTag > 200 ? 'or more' : '' } objects</p>` : ''}`">
      <template v-slot:trigger>
        <div
          class="default_tag_widget circle-button btn-tag-add"
          @click="createTag()"/>
      </template>
    </tippy-component>

    <tippy-component
      v-else
      animation="scale"
      placement="bottom"
      size="small"
      :inertia="true"
      :arrow="true"
      :content="`<p>Remove tag: ${getDefaultElement().firstChild.firstChild.textContent}.${showCount ? `<br>Used already on ${countTag} ${countTag > 200 ? 'or more' : '' } objects</p>` : ''}`">
      <template v-slot:trigger>
        <div
          class="default_tag_widget circle-button btn-tag-delete"
          @click="deleteTag()"/>
      </template>
    </tippy-component>
  </div>
  <div
    v-else
    class="btn-tag circle-button btn-disabled"/>
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
      type: String
    },
    showCount: {
      type: Boolean,
      default: false
    },
    count: {
      type: [Number, String],
      default: undefined
    }
  },
  data: function () {
    return {
      tagItem: undefined,
      keyId: this.getDefault(),
      countTag: undefined,
      created: false
    }
  },
  watch: {
    count: {
      handler (newVal) {
        this.countTag = newVal
      },
      immediate: true
    }
  },
  mounted () {
    this.alreadyTagged()
    document.addEventListener('pinboard:insert', (event) => {
      const details = event.detail
      console.log(details)
      if (details.type === 'ControlledVocabularyTerm') {
        this.keyId = this.getDefault()
        if (this.showCount) {
          this.getCount()
        }
        this.alreadyTagged()
      }
    })
  },
  methods: {
    getDefault () {
      const defaultTag = this.getDefaultElement()
      return defaultTag ? defaultTag.getAttribute('data-pinboard-object-id') : undefined
    },
    getDefaultElement () {
      return document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')
    },
    alreadyTagged: function(element) {
      if(!this.keyId) return

      let params = {
        global_id: this.globalId,
        keyword_id: this.keyId
      }
      AjaxCall('get', '/tags/exists', { params: params }).then(response => {
        if (response.body) {
          this.created = true
        } else {
          this.created = false
        }
      })
    },
    getCount () {
      if (!this.keyId) return
      const params = {
        keyword_id: [this.keyId],
        per: 100
      }
      AjaxCall('get', '/tags', { params: params }).then(response => {
        this.countTag = response.body.length
      })
    },
    createTag: function () {
      let tagItem = {
        tag: {
          keyword_id: this.keyId,
          annotated_global_entity: this.globalId
        }
      }
      AjaxCall('post', '/tags', tagItem).then(response => {
        this.tagItem = response.body
        this.created = true
        TW.workbench.alert.create('Tag item was successfully created.', 'notice')
      })
    },
    deleteTag: function () {
			let tag = {
				annotated_global_entity: this.globalId,
				_destroy: true
			}
      AjaxCall('delete', `/tags/${this.tagItem.id}`, { tag: tag }).then(response => {
        this.created = false
        TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>