<template>
  <div v-if="sourceId">
    <tippy-component
      v-if="!created"
      animation="scale"
      placement="bottom"
      size="small"
      arrow-size="small"
      :inertia="true"
      :arrow="true"
      :content="`<p>Create citation with: ${getDefaultElement().firstChild.firstChild.textContent}</p>`">
      <template v-slot:trigger>
        <div
          class="circle-button button-submit btn-citation"
          @click="createCitation()"/>
      </template>
    </tippy-component>

    <tippy-component
      v-else
      animation="scale"
      placement="bottom"
      size="small"
      arrow-size="small"
      :inertia="true"
      :arrow="true"
      :content="`<p>Remove citation: ${getDefaultElement().firstChild.firstChild.textContent}`">
      <template v-slot:trigger>
        <div
          class="circle-button btn-delete btn-citation"
          @click="deleteCitation()"/>
      </template>
    </tippy-component>
  </div>
  <div
    v-else
    class="btn-citation circle-button btn-disabled"/>
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
    }
  },
  data: function () {
    return {
      citationItem: undefined,
      sourceId: this.getDefault(),
      created: false
    }
  },
  mounted () {
    document.addEventListener('pinboard:insert', (event) => {
      const details = event.detail
      if (details.type === 'Source') {
        this.sourceId = this.getDefault()
      }
    })
  },
  methods: {
    getDefault () {
      const defaultSource = this.getDefaultElement()
      return defaultSource ? defaultSource.getAttribute('data-pinboard-object-id') : undefined
    },
    getDefaultElement () {
      return document.querySelector('[data-pinboard-section="Sources"] [data-insert="true"]')
    },
    createCitation: function () {
      let citationItem = {
        citation: {
          source_id: this.sourceId,
          annotated_global_entity: this.globalId
        }
      }
      AjaxCall('post', '/citations', citationItem).then(response => {
        this.citationItem = response.body
        this.created = true
        TW.workbench.alert.create('Citation item was successfully created.', 'notice')
      }, (response) => {
        TW.workbench.alert.create(JSON.stringify(response.body), 'error')
      })
    },
    deleteCitation: function () {
			let citation = {
				annotated_global_entity: this.globalId,
				_destroy: true
			}
      AjaxCall('delete', `/citations/${this.citationItem.id}`, { citation: citation }).then(response => {
        this.created = false
        TW.workbench.alert.create('Citation item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>