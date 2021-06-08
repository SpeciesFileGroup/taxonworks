<template>
  <div
    v-if="citations.length"
    class="citation-count"
    @mouseover="showCitations = true"
    @mouseout="showCitations = false">
    <span class="button-data circle-button btn-citation">
      <span class="circle-count button-default middle">{{ citations.length }} </span>
    </span>
    <div
      v-show="showCitations"
      class="citation-tooltip-list panel">
      <display-list 
        :list="citations"
        :label="['citation_source_body']"
        @delete="removeCitation"
        :edit="false">
        <div
          slot="options"
          slot-scope="slotProps">
          <display-source :source="slotProps.item.source"/>
        </div>
      </display-list>
    </div>
  </div>
</template>

<script>

import CRUD from '../../request/crud.js'
import DisplayList from 'components/displayList'
import DisplaySource from './displaySource'

export default {
  mixins: [CRUD],
  components: {
    DisplayList,
    DisplaySource
  },
  props: {
    object: {
      type: Object,
      required: true
    },
    target: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      showCitations: false,
      citations: []
    }
  },
  mounted() {
    this.loadCitations()
    document.addEventListener('radial:post', this.refreshCitations)
    document.addEventListener('radial:patch', this.refreshCitations)
    document.addEventListener('radial:delete', this.refreshCitations)
  },
  unmounted () {
    document.removeEventListener('radial:post', this.refreshCitations)
    document.removeEventListener('radial:patch', this.refreshCitations)
    document.removeEventListener('radial:delete', this.refreshCitations)
  },
  methods: {
    removeCitation(cite) {
      this.destroy(`/citations/${cite.id}.json`).then(response => {
        this.citations.splice(this.citations.findIndex(item => { return item.id == cite.id }), 1)
      })
    },
    loadCitations() {
      this.getList(`/${this.target}/${this.object.id}/citations.json`).then(response => {
        this.citations = response.body
      })
    },
    refreshCitations(event) {
      if(event) {
        if(event.detail.object.hasOwnProperty('citation') || 
        (event.detail.object.hasOwnProperty('base_class') && 
        event.detail.object.base_class == 'Citation')) {
          this.loadCitations()
        }
      }
    }
  }
}
</script>
