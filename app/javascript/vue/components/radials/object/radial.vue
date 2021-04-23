<template>
  <div>
    <div class="radial-annotator">
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
              @updateCount="setTotal"
              @close="closeModal"/>
          </div>
        </div>
      </modal>
      <span
        v-if="showBottom"
        :title="buttonTitle"
        type="button"
        class="circle-button button-default"
        :class="[buttonClass]"
        @click="displayAnnotator()">Radial annotator
      </span>
      <div
        v-if="metadataCount && showCount"
        class="circle-count button-submit middle">
        <span class="citation-count-text">{{ metadataCount }}</span>
      </div>
    </div>
  </div>
</template>
<script>

import RadialMenu from 'components/radials/RadialMenu.vue'
import modal from 'components/modal.vue'
import spinner from 'components/spinner.vue'

import CRUD from './request/crud'

import data_attributesAnnotator from './components/data_attribute/data_attribute_annotator.vue'
import biological_associationsAnnotator from './components/biological_relationships/biological_relationships_annotator.vue'
import asserted_distributionsAnnotator from './components/asserted_distributions/asserted_distributions_annotator.vue'
import common_namesAnnotator from './components/common_names/main.vue'
import contentsAnnotator from './components/contents/main.vue'
import biocuration_classificationsAnnotator from './components/biocurations/biocurations'
import taxon_determinationsAnnotator from './components/taxon_determinations/taxon_determinations'
import observation_matricesAnnotator from './components/observation_matrices/main.vue'
import collecting_eventAnnotator from './components/collecting_event/main.vue'
import origin_relationshipsAnnotator from './components/origin_relationship/main'

import Icons from './images/icons.js'

export default {
  mixins: [CRUD],
  name: 'RadialAnnotator',
  components: {
    RadialMenu,
    modal,
    spinner,
    data_attributesAnnotator,
    biological_associationsAnnotator,
    asserted_distributionsAnnotator,
    common_namesAnnotator,
    contentsAnnotator,
    biocuration_classificationsAnnotator,
    taxon_determinationsAnnotator,
    observation_matricesAnnotator,
    collecting_eventAnnotator,
    origin_relationshipsAnnotator
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
      default: 'btn-hexagon-w'
    },
    buttonTitle: {
      type: String,
      default: 'Quick forms'
    },
    showCount: {
      type: Boolean,
      default: false
    },
    components: {
      type: Object,
      default: () => {
        return {}
      }
    },
    type: {
      type: String,
      default: 'graph'
    }
  },
  data: function () {
    return {
      currentAnnotator: undefined,
      display: false,
      url: undefined,
      globalIdSaved: undefined,
      metadata: undefined,
      title: 'Otu radial',
      defaultTag: undefined,
      tagCreated: false,
      hardcodeSections: [
        {
          section: 'observation_matrices',
          objectTypes: ['Otu', 'CollectionObject']
        }
      ]
    }
  },
  computed: {
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
    menuCreated () {
      return this.metadata?.endpoints
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
          fill: this.getDefault() ? (this.isTagged ? '#F44336' : '#9ccc65') : '#CACACA'
        }
      }
    }
  },
  mounted () {
    if (this.showCount) {
      this.loadMetadata()
    }
  },
  methods: {
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
      this.currentAnnotator = undefined
      this.loadMetadata()
      this.alreadyTagged()
    },
    loadMetadata: function () {
      if (this.globalId == this.globalIdSaved && this.menuCreated && !this.reload) return
      this.globalIdSaved = this.globalId

      const that = this
      this.getList(`/${this.type}/${encodeURIComponent(this.globalId)}/metadata`).then(response => {
        that.metadata = response.body
        that.metadata.endpoints = Object.assign({}, that.metadata.endpoints, ...this.addHardcodeSections(response.body.object_type))
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
    },
    addHardcodeSections (type) {
      return this.hardcodeSections.filter(item => item.objectTypes.includes(type)).map(item => {
        return { [item.section]: { total: 0 } }
      })
    }
  }
}
</script>
