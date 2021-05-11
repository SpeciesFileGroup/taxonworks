<template>
  <div>
    <div
      class="radial-annotator">
      <modal
        v-if="display"
        :container-style="{ backgroundColor: 'transparent', boxShadow: 'none' }"
        @close="closeModal()">
        <h3
          slot="header"
          class="flex-separate">
          <span v-html="title" />
          <span
            v-if="metadata"
            class="separate-right">
            {{ metadata.object_type }}
          </span>
        </h3>
        <div
          slot="body"
          class="flex-separate">
          <spinner v-if="!menuCreated" />
          <div class="radial-annotator-menu">
            <div>
              <radial-menu
                v-if="menuCreated"
                :options="menuOptions"
                @onClick="selectComponent"/>
            </div>
          </div>
          <div
            class="radial-annotator-template panel"
            :style="{ 'max-height': windowHeight(), 'min-height': windowHeight() }"
            v-if="currentAnnotator">
            <h2 class="capitalize view-title">
              {{ currentAnnotator.replace("_"," ") }}
            </h2>
            <component
              class="radial-annotator-container"
              :is="(currentAnnotator ? currentAnnotator + 'Annotator' : undefined)"
              :type="currentAnnotator"
              :url="url"
              :metadata="metadata"
              :global-id="globalId"
              :object-type="metadata.object_type"
              @updateCount="setTotal"/>
          </div>
        </div>
      </modal>
      <span
        v-if="showBottom"
        :title="globalId ? `${globalId.split('/')[3]} annotator` : buttonTitle"
        type="button"
        class="circle-button"
        :class="[buttonClass, pulse ? 'pulse-blue' : '']"
        @contextmenu.prevent="loadContextMenu"
        @click="displayAnnotator()">Radial annotator
      </span>
      <div
        v-if="metadataCount && showCount"
        class="circle-count button-submit middle">
        <span class="citation-count-text">{{ metadataCount }}</span>
      </div>
      <context-menu
        :metadata="metadata"
        :global-id="globalId"
        v-model="showContextMenu"
        v-if="showContextMenu"/>
    </div>
  </div>
</template>
<script>

import RadialMenu from 'components/radials/RadialMenu.vue'
import modal from 'components/ui/Modal.vue'
import spinner from 'components/spinner.vue'

import CRUD from './request/crud'

import confidencesAnnotator from './components/confidence_annotator.vue'
import depictionsAnnotator from './components/depiction_annotator.vue'
import documentationAnnotator from './components/documentation_annotator.vue'
import identifiersAnnotator from './components/identifier/identifier_annotator.vue'
import tagsAnnotator from './components/tag_annotator.vue'
import notesAnnotator from './components/note_annotator.vue'
import data_attributesAnnotator from './components/data_attribute_annotator.vue'
import alternate_valuesAnnotator from './components/alternate_value_annotator.vue'
import citationsAnnotator from './components/citations/citation_annotator.vue'
import protocol_relationshipsAnnotator from './components/protocol_annotator.vue'
import attributionAnnotator from './components/attribution/main.vue'

import ContextMenu from './components/contextMenu'

import Icons from './images/icons.js'

export default {
  mixins: [CRUD],
  name: 'RadialAnnotator',
  components: {
    RadialMenu,
    modal,
    spinner,
    notesAnnotator,
    citationsAnnotator,
    confidencesAnnotator,
    depictionsAnnotator,
    data_attributesAnnotator,
    documentationAnnotator,
    alternate_valuesAnnotator,
    identifiersAnnotator,
    tagsAnnotator,
    protocol_relationshipsAnnotator,
    attributionAnnotator,
    ContextMenu
  },
  props: {
    reload: {
      type: Boolean,
      default: false
    },
    globalId: {
      type: String,
      required: true
    },
    showBottom: {
      type: Boolean,
      default: true
    },
    buttonClass: {
      type: String,
      default: 'btn-radial'
    },
    buttonTitle: {
      type: String,
      default: 'Radial annotator'
    },
    showCount: {
      type: Boolean,
      default: false
    },
    defaultView: {
      type: String,
      default: undefined
    },
    components: {
      type: Object,
      default: () => {
        return {}
      }
    },
    type: {
      type: String,
      default: 'annotations'
    },
    pulse: {
      type: Boolean,
      default: false
    }
  },
  data () {
    return {
      currentAnnotator: undefined,
      display: false,
      url: undefined,
      globalIdSaved: undefined,
      metadata: undefined,
      title: 'Radial annotator',
      defaultTag: undefined,
      tagCreated: false,
      showContextMenu: false
    }
  },
  computed: {
    metadataLoaded () {
      return (this.globalId === this.globalIdSaved && this.menuCreated && !this.reload)
    },

    menuCreated () {
      return this.metadata?.endpoints
    },

    menuOptions () {
      const endpoints = this.metadata.endpoints || {}

      const slices = Object.entries(endpoints).map(([annotator, { total }]) => ({
        name: annotator,
        label: (annotator.charAt(0).toUpperCase() + annotator.slice(1)).replace('_', ' '),
        innerPosition: 1.7,
        svgAttributes: {
          fill: this.currentAnnotator === annotator ? '#8F8F8F' : undefined
        },
        slices: total
          ? [{
              label: total.toString(),
              size: 26,
              svgAttributes: {
                fill: '#006ebf',
                color: '#FFFFFF'
              }
            }]
          : [],
        icon: Icons[annotator]
          ? {
              url: Icons[annotator],
              width: '20',
              height: '20'
            }
          : undefined
      }))

      return {
        width: 400,
        height: 400,
        sliceSize: 120,
        centerSize: 34,
        margin: 2,
        middleButton: this.middleButton,
        css: {
          class: 'svg-radial-annotator'
        },
        svgAttributes: {
          fontSize: 11,
          fill: '#FFFFFF',
          textAnchor: 'middle'
        },
        slices: slices
      }
    },

    metadataCount () {
      if (this.metadata) {
        let totalCounts = 0
        for (const key in this.metadata.endpoints) {
          const section = this.metadata.endpoints[key]
          if (typeof section === 'object') {
            totalCounts = totalCounts + Number(section.total)
          }
        }
        return totalCounts
      }
      return undefined
    },
    isTagged () {
      return this.tagCreated
    },
    middleButton () {
      return {
        name: 'circleButton',
        radius: 30,
        icon: {
          url: Icons.tags,
          width: '20',
          height: '20'
        },
        svgAttributes: {
          fontSize: 11,
          fill: this.getDefault() ? (this.isTagged ? '#F44336' : '#9ccc65') : '#CACACA',
          style: 'cursor: pointer'
        },
        backgroundHover: this.getDefault() ? (this.isTagged ? '#CE3430' : '#81a553') : '#CACACA'
      }
    }
  },
  watch: {
    metadataLoaded () {
      if (this.defaultView) {
        this.currentAnnotator = this.defaultView ? (this.isComponentExist(this.defaultView) ? this.defaultView : undefined) : undefined
      }
    },
    display (newVal) {
      if (newVal && this.metadataLoaded) {
        this.currentAnnotator = this.defaultView ? (this.isComponentExist(this.defaultView) ? this.defaultView : undefined) : undefined
      }
    }
  },
  mounted () {
    if (this.showCount) {
      this.loadMetadata()
    }
  },
  methods: {
    isComponentExist (componentName) {
      return this.$options.components[componentName] ? true : false
    },
    loadContextMenu () {
      this.showContextMenu = true
      this.loadMetadata()
    },
    getDefault () {
      const defaultTag = document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')
      return defaultTag ? defaultTag.getAttribute('data-pinboard-object-id') : undefined
    },
    alreadyTagged: function() {
      const keyId = this.getDefault()
      if( !keyId) return

      let params = {
        global_id: this.globalId,
        keyword_id: keyId
      }
      this.getList('/tags/exists', { params: params }).then(response => {
        if(response.body) {
          this.defaultTag = response.body
          this.tagCreated = true
        }
        else {
          this.tagCreated = false
        }
      })
    },
    selectComponent ({ name }) {
      if (name === 'circleButton') {
        if (this.getDefault()) {
          this.isTagged ? this.deleteTag() : this.createTag()
        }
      }
      else {
        this.currentAnnotator = name
      }
    },
    closeModal: function () {
      this.display = false
      this.eventClose()
      this.$emit('close')
    },
    displayAnnotator: function () {
      this.display = true
      this.loadMetadata()
      this.alreadyTagged()
    },
    loadMetadata: function () {
      if (this.globalId == this.globalIdSaved && this.menuCreated && !this.reload) return
      this.globalIdSaved = this.globalId

      const that = this
      this.getList(`/${this.type}/${encodeURIComponent(this.globalId)}/metadata`).then(response => {
        that.metadata = response.body
        that.title = response.body.object_tag
        that.url = response.body.url
      })
    },
    setTotal (total) {
      this.metadata.endpoints[this.currentAnnotator].total = total
    },
    eventClose: function () {
      const event = new CustomEvent('annotator:close', {
        detail: {
          metadata: this.metadata
        }
      })
      document.dispatchEvent(event)
    },
    windowHeight () {
      return ((window.innerHeight - 100) > 650 ? 650 : window.innerHeight - 100) + 'px !important'
    },
    createTag: function () {
      let tagItem = {
        tag: {
          keyword_id: this.getDefault(),
          annotated_global_entity: this.globalId
        }
      }
      this.create('/tags', tagItem).then(response => {
        this.defaultTag = response.body
        this.tagCreated = true
        TW.workbench.alert.create('Tag item was successfully created.', 'notice')
      })
    },
    deleteTag: function () {
      let tag = {
        annotated_global_entity: this.globalId,
        _destroy: true
      }
      this.destroy(`/tags/${this.defaultTag.id}`, { tag: tag }).then(response => {
        this.tagCreated = false
        this.defaultTag = undefined
        TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>
<style lang="scss">
  .svg-radial-annotator {
    g:hover {
      cursor: pointer;
      opacity: 0.9;
    }
  }
  .radial-annotator {
    position: relative;

    .modal-close {
      top: 30px;
      right: 20px;
    }
    .modal-mask {
      background-color: rgba(0, 0, 0, 0.7);
    }
    .modal-container {
      min-width: 1024px;
      width: 1200px;
    }
    .radial-annotator-template {
      border-radius: 3px;
      background: #FFFFFF;
      padding: 1em;
      width: 100%;
      max-width: 100%;
      min-height: 600px;
    }
    .radial-annotator-container {
      display: flex;
      height: 600px;
      flex-direction: column;
      overflow-y: scroll;
      position: relative;
    }
    .radial-annotator-menu {
      padding-top: 1em;
      padding-bottom: 1em;
      width: 700px;
      min-height: 650px;
    }
    .annotator-buttons-list {
      overflow-y: scroll;
    }
    .save-annotator-button {
      width: 100px;
    }
    .circle-count {
      bottom: -6px;
    }
  }

  .tag_button {
    padding-left: 12px;
    padding-right: 8px;
    width: auto !important;
    min-width: auto !important;
    cursor: pointer;
    margin: 2px;
    border: none;
    border-top-left-radius: 15px;
    border-bottom-left-radius: 15px;
  }
</style>
