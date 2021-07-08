<template>
  <div class="flexbox align-start">
    <block-layout :warning="!collectionObject.id">
      <template #header>
        <h3>Collection Object</h3>
      </template>
      <template #options>
        <div
          v-hotkey="shortcuts"
          v-if="collectionObject.id"
          class="horizontal-left-content">
          <radial-annotator
            classs="separate-right"
            :global-id="collectionObject.global_id"/>
          <default-tag
            classs="separate-right"
            :global-id="collectionObject.global_id"/>
          <radial-object
            v-if="collectionObject.id"
            :global-id="collectionObject.global_id"/>
        </div>
      </template>
      <template #body>
        <div
          class="horizontal-left-content align-start flexbox separate-bottom">
          <div class="separate-right">
            <catalogue-number/>
          </div>
          <div class="separate-left separate-right">
            <repository-component/>
          </div>
          <div class="separate-left separate-right">
            <preparation-type/>
          </div>
        </div>
        <div class="horizontal-right-content">
          <buffered-component
            class="separate-top separate-right"/>
        </div>
        <div class="horizontal-right-content separate-top separate-bottom">
          <depictions-component
            class="separate-top separate-right"
            :object-value="collectionObject"
            :get-depictions="GetCollectionObjectDepictions"
            object-type="CollectionObject"
            @create="createDepictionForAll"
            @delete="removeAllDepictionsByImageId"
            default-message="Drop images or click here<br> to add collection object figures"
            action-save="SaveCollectionObject"/>
        </div>
        <div class="horizontal-left-content align-start">
          <citation-component class="separate-right full_width"/>
          <div class="full_width">
            <spinner-component
              v-if="!collectionObject.id"
              :show-spinner="false"
              :legend-style="{
                color: '#444',
                textAlign: 'center'
              }"
              legend="Locked until first save"/>
            <h2>Attributes</h2>
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
        <container-items/>
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
import RadialObject from 'components/radials/navigation/radial.vue'
import PredicatesComponent from 'components/custom_attributes/predicates/predicates'
import DefaultTag from 'components/defaultTag.vue'
import platformKey from 'helpers/getMacKey'

import { GetCollectionObjectDepictions } from '../../request/resources.js'
import { Depiction, User } from 'routes/endpoints'

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
    DefaultTag
  },
  computed: {
    preferences: {
      get () {
        return this.$store.getters[GetterNames.GetPreferences]
      },
      set (value) {
        this.$store.commit(MutationNames.SetPreferences, value)
      }
    },
    projectPreferences () {
      return this.$store.getters[GetterNames.GetProjectPreferences]
    },
    collectionObject () {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    collectionObjects() {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
    depictions: {
      get () {
        return this.$store.getters[GetterNames.GetDepictions]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDepictions)
      }
    },
    total: {
      get() {
        return this.$store.getters[GetterNames.GetCollectionObject].total
      },
      set(value) {
        this.$store.commit(MutationNames.SetCollectionObjectTotal, value)
      }
    },
    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+e`] = this.openBrowse

      return keys
    },
  },
  data() {
    return {
      types: [],
      labelRepository: undefined,
      labelEvent: undefined,
      GetCollectionObjectDepictions
    }
  },
  watch: {
    collectionObject(newVal) {
      if(newVal.id) {
        this.cloneDepictions(newVal)
      }
    }
  },
  methods: {
    setAttributes (value) {
      this.$store.commit(MutationNames.SetCollectionObjectDataAttributes, value)
    },
    updatePreferences (key, value) {
      User.update(this.preferences.id, { user: { layout: { [key]: value } } }).then(response => {
        this.preferences.layout = response.body.preferences.layout
      })
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
    cloneDepictions(co) {
      const unique = new Set()
      const depictionsRemovedDuplicate = this.depictions.filter(depiction => {
        let key = depiction.image_id,
          isNew = !unique.has(key)
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
    saveDepiction(coId, depiction) {
      const data = {
        depiction_object_id: coId,
        depiction_object_type: 'CollectionObject',
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