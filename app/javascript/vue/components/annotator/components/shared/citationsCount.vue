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
import DisplayList from '../../../displayList'
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
  destroyed() {
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

<style lang="scss">
  .citation-count {
    position: relative;
  }
  .citation-count-text {
    position: relative;
    font-size: 100%;
    justify-content: center
  }
  .citation-tooltip-list {
    position: fixed;
    min-width: 300px;
    transform: translateX(-50%);
    z-index: 30;
  }
  .circle-count {
    right:-2px;
    bottom: -2px;
    justify-content: center;
    position: absolute;
    border-radius: 50%;
    display: flex;
    width: 12px;
    height: 12px;
    min-width: 12px;
    min-height: 12px;
    font-size: 8px;
    box-shadow: 0px 1px 2px 0px #EBEBEB;
    margin: 5px;
    cursor: pointer;
  }
</style>
