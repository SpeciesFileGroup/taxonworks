<template>
  <div class="flexbox align-start">
    <block-layout :warning="!collectionObject.id">
      <template #header>
        <h3>Collection Object</h3>
      </template>
      <template #options>
        <div
          v-if="collectionObject.id"
          v-hotkey="shortcuts"
          class="horizontal-left-content">
          <radial-annotator :global-id="collectionObject.global_id" />
          <default-tag :global-id="collectionObject.global_id" />
          <radial-object :global-id="collectionObject.global_id" />
          <radial-navigation :global-id="collectionObject.global_id" />
        </div>
      </template>
      <template #body>
        <div id="collection-object-form">
          <catalogue-number
            v-if="showCatalogNumber"
            class="panel content" />
          <repository-component
            v-if="showRepository"
            class="panel content" />
          <preparation-type
            v-if="showPreparation"
            class="panel content" />
          <div
            v-if="showBuffered"
            class="panel content">
            <h2 class="flex-separate">
              Buffered
            </h2>
            <buffered-component
              class="field"/>
          </div>
          <div
            v-if="showDepictions"
            class="panel content column-depictions">
            <h2 class="flex-separate">
              Depictions
            </h2>
            <depictions-component
              v-if="showDepictions"
              :object-value="collectionObject"
              :get-depictions="GetCollectionObjectDepictions"
              object-type="CollectionObject"
              @create="createDepictionForAll"
              @delete="removeAllDepictionsByImageId"
              default-message="Drop images or click here<br> to add collection object figures"
              action-save="SaveCollectionObject"/>
          </div>
          <soft-validations
            v-if="showValidations"
            class="column-validation"
            :validations="validations"
          />
          <div
            v-if="showCitations"
            class="panel content column-citations">
            <h2 class="flex-separate">
              Citations
            </h2>
            <citation-component/>
          </div>
          <div
            v-if="showAttributes"
            class="panel content column-attribute">
            <h2 class="flex-separate">
              Attributes
            </h2>
            <div>
              <spinner-component
                v-if="!collectionObject.id"
                :show-spinner="false"
                :legend-style="{
                  color: '#444',
                  textAlign: 'center'
                }"
                legend="Locked until first save"/>
              <predicates-component
                v-if="projectPreferences"
                :object-id="collectionObject.id"
                object-type="CollectionObject"
                model="CollectionObject"
                :model-preferences="projectPreferences.model_predicate_sets.CollectionObject"
                @onUpdate="setAttributes"
              />
            </div>
          </div>
          <container-items class="row-item"/>
        </div>
      </template>
    </block-layout>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import ContainerItems from './containerItems.vue'
import PreparationType from './preparationType.vue'
import CatalogueNumber from '../catalogueNumber/catalogNumber.vue'
import BufferedComponent from './bufferedData.vue'
import DepictionsComponent from '../shared/depictions.vue'
import RepositoryComponent from './repository.vue'
import CitationComponent from './Citation/CitationMain.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions'
import BlockLayout from 'components/layout/BlockLayout.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import RadialObject from 'components/radials/object/radial.vue'
import PredicatesComponent from 'components/custom_attributes/predicates/predicates'
import DefaultTag from 'components/defaultTag.vue'
import platformKey from 'helpers/getPlatformKey'
import SoftValidations from 'components/soft_validations/panel.vue'
import {
  Depiction,
  CollectionObject
} from 'routes/endpoints'
import { COLLECTION_OBJECT } from 'constants/index.js'
import {
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CITATIONS,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_ATTRIBUTES,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_BUFFERED,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_DEPICTIONS,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_PREPARATION,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_REPOSITORY,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CATALOG_NUMBER,
  COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_VALIDATIONS
} from 'tasks/digitize/const/layout'

export default {
  components: {
    CitationComponent,
    SpinnerComponent,
    ContainerItems,
    PreparationType,
    CatalogueNumber,
    BufferedComponent,
    DepictionsComponent,
    RepositoryComponent,
    BlockLayout,
    RadialAnnotator,
    PredicatesComponent,
    RadialObject,
    DefaultTag,
    RadialNavigation,
    SoftValidations
  },

  computed: {
    projectPreferences () {
      return this.$store.getters[GetterNames.GetProjectPreferences]
    },

    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    },

    collectionObjects () {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },

    depictions: {
      get () {
        return this.$store.getters[GetterNames.GetDepictions]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDepictions, value)
      }
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+e`] = this.openBrowse

      return keys
    },

    validations () {
      const { Specimen } = this.$store.getters[GetterNames.GetSoftValidations]

      return Specimen
        ? { Specimen }
        : {}
    },

    layout () {
      return this.$store.getters[GetterNames.GetPreferences]?.layout || {}
    },

    showAttributes () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_ATTRIBUTES]
    },

    showBuffered () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_BUFFERED]
    },

    showCitations () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CITATIONS]
    },

    showDepictions () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_DEPICTIONS]
    },

    showPreparation () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_PREPARATION]
    },

    showRepository () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_REPOSITORY]
    },

    showCatalogNumber () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_CATALOG_NUMBER]
    },

    showValidations () {
      return !this.layout[COMPREHENSIVE_COLLECTION_OBJECT_LAYOUT_VALIDATIONS]
    }
  },

  data () {
    return {
      types: [],
      labelRepository: undefined,
      labelEvent: undefined,
      GetCollectionObjectDepictions: CollectionObject.depictions
    }
  },
  watch: {
    collectionObject(newVal) {
      if (newVal.id) {
        this.cloneDepictions(newVal)
      }
    }
  },
  methods: {
    setAttributes (value) {
      this.collectionObject.data_attributes_attributes = value
    },

    newDigitalization () {
      this.$store.dispatch(ActionNames.NewCollectionObject)
      this.$store.dispatch(ActionNames.NewIdentifier)
      this.$store.commit(MutationNames.NewTaxonDetermination)
      this.$store.commit(MutationNames.SetTaxonDeterminations, [])
    },

    saveCollectionObject() {
      this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
        this.$store.commit(MutationNames.SetTaxonDeterminations, [])
      })
    },

    saveAndNew() {
      this.$store.dispatch(ActionNames.SaveDigitalization).then(() => {
        setTimeout(() => {
          this.newDigitalization()
        }, 500)
      })
    },

    cloneDepictions (co) {
      const unique = new Set()
      const depictionsRemovedDuplicate = this.depictions.filter(depiction => {
        const key = depiction.image_id
        const isNew = !unique.has(key)

        if (isNew) unique.add(key)
        return isNew
      })

      const coDepictions = this.depictions.filter(depiction => depiction.depiction_object_id === co.id)

      depictionsRemovedDuplicate.forEach(depiction => {
        if (!coDepictions.find(item => item.image_id === depiction.image_id)) {
          this.saveDepiction(co.id, depiction)
        }
      })
    },

    saveDepiction (coId, depiction) {
      const data = {
        depiction_object_id: coId,
        depiction_object_type: COLLECTION_OBJECT,
        image_id: depiction.image_id
      }
      Depiction.create({ depiction: data }).then(response => {
        this.depictions.push(response.body)
      })
    },

    createDepictionForAll(depiction) {
      const coIds = this.collectionObjects.map((co) => co.id).filter(id => this.collectionObject.id !== id)

      this.depictions.push(depiction)
      coIds.forEach((id) => {
        this.saveDepiction(id, depiction)
      })
    },

    removeAllDepictionsByImageId(depiction) {
      this.$store.dispatch(ActionNames.RemoveDepictionsByImageId, depiction)
    },

    openBrowse () {
      if (this.collectionObject.id) {
        window.open(`/tasks/collection_objects/browse?collection_object_id=${this.collectionObject.id}`, '_self')
      }
    }
  }
}
</script>

<style scoped>
  #collection-object-form {
    display: grid;
    grid-template-columns: repeat(3, minmax(250px, 1fr) );
    gap: 0.5em;
    grid-auto-flow: dense;
  }

  .depict-validation-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 0.5em;
  }

  .column-validation {
    grid-column: 3 / 4;
  }

  .row-1-3 {
    grid-column: 1 / 3;
  }
  .row-item {
    grid-column: 1 / 4;
  }
</style>
