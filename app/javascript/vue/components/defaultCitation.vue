<template>
  <div v-if="sourceId">
    <tippy
      v-if="!created"
      animation="scale"
      placement="bottom"
      size="small"
      arrow-size="small"
      inertia
      arrow
      :content="`<p>Create citation with: ${getDefaultElement().firstChild.firstChild.textContent}</p>`">
      <div
        class="circle-button button-submit btn-citation"
        @click="createCitation()"/>
    </tippy>

    <tippy
      v-else
      animation="scale"
      placement="bottom"
      size="small"
      arrow-size="small"
      inertia
      arrow
      :content="`<p>Remove citation: ${getDefaultElement().firstChild.firstChild.textContent}`">
      <div
        class="circle-button btn-delete btn-citation"
        @click="deleteCitation()"/>
    </tippy>
  </div>
  <div
    v-else
    class="btn-citation circle-button btn-disabled"/>
</template>

<script>
import { Tippy } from 'vue-tippy'
import AjaxCall from 'helpers/ajaxCall'

export default {
  components: {
    Tippy
  },
  props: {
    globalId: {
      type: String
    },
    isOriginal: {
      type: Boolean,
      default: false
    },
    citations: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      citationItem: undefined,
      sourceId: this.getDefault(),
      created: false
    }
  },
  created () {
    const citationCreated = this.citations.find(item => item.source_id === Number(this.sourceId))
    if (citationCreated) {
      this.citationItem = citationCreated
      this.created = true
    }
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
    createCitation () {
      const citationItem = {
        citation: {
          source_id: this.sourceId,
          annotated_global_entity: this.globalId,
          is_original: this.isOriginal
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
    deleteCitation () {
      const citationItem = this.citationItem
      const data = {
        annotated_global_entity: this.globalId,
        _destroy: true
      }
      AjaxCall('delete', `/citations/${citationItem.id}`, { citation: data }).then(response => {
        this.created = false
        TW.workbench.alert.create('Citation item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>