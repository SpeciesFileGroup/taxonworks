<template>
  <div>
    <div class="radial-annotator">
      <modal
        v-if="display"
        @close="closeModal()">
        <h3 slot="header">
          <span v-html="title"/>
        </h3>
        <div
          slot="body"
          class="flex-separate">
          <spinner v-if="!menuCreated"/>
          <div class="radial-annotator-menu">
            <div>
              <radial-menu
                v-if="menuCreated"
                :menu="menuOptions"
                @selected="currentAnnotator = $event"
                width="400"
                height="400"/>
            </div>
          </div>
          <div
            class="radial-annotator-template panel"
            :style="{ 'max-height': windowHeight(), 'min-height': windowHeight() }"
            v-if="currentAnnotator">
            <h3 class="capitalize view-title">{{ currentAnnotator.replace("_"," ") }}</h3>
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
        :title="buttonTitle"
        type="button"
        class="circle-button"
        :class="[buttonClass]"
        @click="displayAnnotator()">Radial annotator
      </span>
    </div>
  </div>
</template>
<script>

  import radialMenu from '../radialMenu.vue'
  import modal from '../modal.vue'
  import spinner from '../spinner.vue'

  import CRUD from './request/crud'

  import confidencesAnnotator from './components/confidence_annotator.vue'
  import depictionsAnnotator from './components/depiction_annotator.vue'
  import documentationAnnotator from './components/documentation_annotator.vue'
  import identifiersAnnotator from './components/identifier_annotator.vue'
  import tagsAnnotator from './components/tag_annotator.vue'
  import notesAnnotator from './components/note_annotator.vue'
  import data_attributesAnnotator from './components/data_attribute_annotator.vue'
  import alternate_valuesAnnotator from './components/alternate_value_annotator.vue'
  import citationsAnnotator from './components/citations/citation_annotator.vue'
  import protocol_relationshipsAnnotator from './components/protocol_annotator.vue'
  import biological_associationsAnnotator from './components/biological_relationships/biological_relationships_annotator.vue'
  import asserted_distributionsAnnotator from './components/asserted_distributions/asserted_distributions_annotator.vue'
  import common_namesAnnotator from './components/common_names/main.vue'
  import contentsAnnotator from './components/contents/main.vue'

  import Icons from './images/icons.js'

  export default {
    mixins: [CRUD],
    name: 'RadialAnnotator',
    components: {
      radialMenu,
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
      biological_associationsAnnotator,
      asserted_distributionsAnnotator,
      common_namesAnnotator,
      contentsAnnotator
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
      components: {
        type: Object,
        default: () => {
          return {}
        }
      },
      type: {
        type: String,
        default: 'annotations'
      }
    },
    data: function () {
      return {
        currentAnnotator: undefined,
        display: false,
        url: undefined,
        globalIdSaved: undefined,
        metadata: undefined,
        title: 'Radial annotator',
        menuOptions: []
      }
    },
    computed: {
      menuCreated() {
        return this.menuOptions.length > 0
      }
    },
    methods: {
      closeModal: function () {
        this.display = false
        this.eventClose()
        this.$emit('close')
      },
      displayAnnotator: function () {
        this.display = true
        this.currentAnnotator = undefined
        this.loadMetadata()
      },
      loadMetadata: function () {
        if (this.globalId == this.globalIdSaved && this.menuCreated && !this.reload) return
        this.globalIdSaved = this.globalId

        let that = this
        this.getList(`/${this.type}/${encodeURIComponent(this.globalId)}/metadata`).then(response => {
          that.metadata = response.body
          that.title = response.body.object_tag
          that.menuOptions = that.createMenuOptions(response.body.endpoints)
          that.url = response.body.url
        })
      },
      createMenuOptions: function (annotators) {
        let menu = []

        for (var key in annotators) {
          menu.push({
            label: (key.charAt(0).toUpperCase() + key.slice(1)).replace('_', ' '),
            total: annotators[key].total,
            event: key,
            icon: {
              url: Icons[key],
              width: '20',
              height: '20'
            }
          })
        }
        return menu
      },
      setTotal(total) {
        var that = this
        let position = this.menuOptions.findIndex(function (element) {
          return element.event == that.currentAnnotator
        })
        this.menuOptions[position].total = total
      },
      eventClose: function () {
        let event = new CustomEvent('annotator:close', {
          detail: {
            metadata: this.metadata
          }
        })
        document.dispatchEvent(event)
      },
      windowHeight() {
        return ((window.innerHeight - 100) > 650 ? 650 : window.innerHeight-100) + 'px !important'
      }
    }
  }
</script>
<style lang="scss">

  .radial-annotator {
    .view-title {
      font-size: 18px;
      font-weight: 300;
    }
    .modal-close {
      top: 30px;
      right: 20px;
    }
    .modal-mask {
      background-color: rgba(0, 0, 0, 0.7);
    }
    .modal-container {
      box-shadow: none;
      background-color: transparent;
    }
    .modal-container {
      min-width: 1024px;
      width: 1024px;
    }
    .radial-annotator-template {
      border-radius: 3px;
      background: #FFFFFF;
      padding: 1em;
      width: 50%;
      max-width: 50%;
      min-height: 600px;
    }
    .radial-annotator-container {
      display: flex;
      height: 600px;
      flex-direction: column;
      button {
        min-width: 100px;
      }
    }
    .radial-annotator-menu {
      padding-top: 1em;
      padding-bottom: 1em;
      width: 50%;
      min-height: 650px;
    }
    .annotator-buttons-list {
      overflow-y: scroll;
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
  }

</style>
