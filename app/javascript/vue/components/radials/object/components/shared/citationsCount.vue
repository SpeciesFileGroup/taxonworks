<template>
  <span>
    <div
      v-if="citations.length"
      class="citation-count"
      @click.prevent="setModalView(true)">
      <span class="circle-button btn-citation button-default">
        <span class="circle-count button-data middle">{{ citations.length }} </span>
      </span>
    </div>
    <modal-component
      v-if="showCitations"
      @close="setModalView(false)">
      <h3 slot="header">Citations</h3>
      <div
        slot="body">
        <display-list
          :list="citations"
          :validations="true"
          :label="['citation_source_body']"
          @delete="removeCitation"
          :edit="false">
          <div
            slot="options"
            slot-scope="slotProps">
            <a
              :title="slotProps.item.source.object_tag"
              class="button-default circle-button btn-citation"
              :href="`/tasks/nomenclature/by_source?source_id=${slotProps.item.source.id}`"
              target="blank"/>
          </div>
        </display-list>
      </div>
    </modal-component>
  </span>
</template>

<script>

import CRUD from '../../request/crud.js'
import DisplayList from 'components/displayList'
import ModalComponent from 'components/ui/Modal'

export default {
  mixins: [CRUD],
  components: {
    DisplayList,
    ModalComponent
  },
  props: {
    object: {
      type: Object,
      required: true
    },
    target: {
      type: String,
      required: true
    },
    values: {
      type: Array,
      default: undefined
    }
  },
  data () {
    return {
      showCitations: false,
      citations: []
    }
  },
  watch: {
    values: {
      handler (newVal) {
        this.citations = newVal
      }
    },
    deep: true
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
      if (!this.values) {
        this.getList(`/${this.target}/${this.object.id}/citations.json`).then(response => {
          this.citations = response.body
        })
      } else {
        this.citations = this.values
      }
    },
    refreshCitations(event) {
      if(event) {
        if(event.detail.object.hasOwnProperty('citation') || 
        (event.detail.object.hasOwnProperty('base_class') && 
        event.detail.object.base_class == 'Citation')) {
          this.loadCitations()
        }
      }
    },
    setModalView (value) {
      this.showCitations = value
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
  .circle-count {
    left:15px;
    bottom: -6px;
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
