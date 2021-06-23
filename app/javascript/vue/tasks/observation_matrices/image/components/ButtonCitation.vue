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

import { Citation } from 'routes/endpoints'
import { TippyComponent } from 'vue-tippy'

export default {
  components: {
    TippyComponent
  },

  props: {
    globalId: {
      type: String,
      required: true
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
      const citation = {
        source_id: this.sourceId,
        annotated_global_entity: this.globalId,
        is_original: true
      }

      Citation.create({ citation }).then(response => {
        this.created = true
        this.citationItem = response.body
        TW.workbench.alert.create('Citation item was successfully created.', 'notice')
      })
    },
    deleteCitation () {
      Citation.destroy(this.citationItem.id).then(() => {
        this.created = false
        TW.workbench.alert.create('Citation item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>