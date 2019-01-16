<template>
  <div class="flexbox align-start">
    <block-layout>
      <div slot="header">
        <h3>Collection Object</h3>
      </div>
      <div
        slot="options"
        class="horizontal-left-content">
        <radial-annotator
          classs="separate-right"
          v-if="collectionObject.id"
          :global-id="collectionObject.global_id"/>
      </div>
      <div slot="body">
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
        <div class="horizontal-left-content">
          <buffered-component
            v-if="showBuffered"
            class="separate-top separate-right"/>
          <div class="middle">
            <btn-show
              class="separate-right"
              :value="showBuffered"
              @input="showBuffered = $event; updatePreferences('tasks::digitize::collectionObjects::showBuffered', showBuffered)"/>
            <span
              v-if="!showBuffered"
              class="separate-left">Show buffered fields
            </span>
          </div>
        </div>
        <div class="horizontal-left-content separate-top">
          <depictions-component
            v-if="showDepictions"
            class="separate-top separate-right"
            :object-value="collectionObject"
            :get-depictions="GetCollectionObjectDepictions"
            object-type="CollectionObject"
            @create="createDepictionForAll"
            @delete="removeAllDepictionsByImageId"
            default-message="Drop images here to add collection object figures"
            action-save="SaveCollectionObject"/>
          <div class="middle">
            <btn-show
              class="separate-right"
              :value="showDepictions"
              @input="showDepictions = $event; updatePreferences('tasks::digitize::collectionObjects::showDepictions', showDepictions)"/>
            <span
              v-if="!showDepictions"
              class="separate-left">Show depictions
            </span>
          </div>
        </div>
        <container-items/>
      </div>
    </block-layout>
  </div>
</template>

<script>

  import ContainerItems from './containerItems.vue'
  import PreparationType from './preparationType.vue'
  import CatalogueNumber from '../catalogueNumber/catalogNumber.vue'
  import TableCollectionObjects from './tableCollectionObjects.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from '../shared/depictions.vue'
  import RepositoryComponent from './repository.vue'
  import { GetterNames } from '../../store/getters/getters'
  import { MutationNames } from '../../store/mutations/mutations.js'
  import { ActionNames } from '../../store/actions/actions'
  import BlockLayout from '../../../../components/blockLayout.vue'
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import LockComponent from 'components/lock.vue'
  import btnShow from 'components/btnShow.vue'
  import { GetCollectionObjectDepictions, CreateDepiction, UpdateUserPreferences } from '../../request/resources.js'

  export default {
    components: {
      LockComponent,
      ContainerItems,
      PreparationType,
      CatalogueNumber,
      TableCollectionObjects,
      Bioclassification,
      BufferedComponent,
      DepictionsComponent,
      RepositoryComponent,
      BlockLayout,
      RadialAnnotator,
      btnShow
    },
    computed: {
      preferences: {
        get() {
          return this.$store.getters[GetterNames.GetPreferences]
        },
        set(value) {
          this.$store.commit(MutationNames.SetPreferences, value)
        }
      },
      collectionObject () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      collectionObjects() {
        return this.$store.getters[GetterNames.GetCollectionObjects]
      },
      depictions: {
        get() {
          return this.$store.getters[GetterNames.GetDepictions]
        },
        set(value) {
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
    },
    data() {
      return {
        types: [],
        labelRepository: undefined,
        labelEvent: undefined,
        showDepictions: true,
        showBuffered: true,
        GetCollectionObjectDepictions
      }
    },
    watch: {
      collectionObject(newVal) {
        if(newVal.id) {
          this.cloneDepictions(newVal)
        }
      },
      preferences: {
        handler(newVal) {
          if(newVal) {
            let layout = newVal['layout']
            if(layout) {
              let sDepictions = layout['tasks::digitize::collectionObjects::showDepictions']
              let sBuffered = layout['tasks::digitize::collectionObjects::showBuffered']
              this.showDepictions = (sDepictions != undefined ? sDepictions : true)
              this.showBuffered = (sBuffered != undefined ? sBuffered : true)
            }
          }
        },
        deep: true
      }
    },
    methods: {
      updatePreferences(key, value) {
        UpdateUserPreferences(this.preferences.id, { [key]: value }).then(response => {
          this.preferences.layout = response.preferences.layout
        })
      },
      getMacKey: function () {
        return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
      },
      newDigitalization() {
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
          let that = this
          setTimeout(() => {
            that.newDigitalization()
          }, 500)
        })
      },
      cloneDepictions(co) {
        let unique = new Set()
        let depictionsRemovedDuplicate = this.depictions.filter(depiction => {
          let key = depiction.image_id, 
          isNew = !unique.has(key);
          if (isNew) unique.add(key);
          return isNew;
        })

        let coDepictions = this.depictions.filter(depiction => {
          return depiction.depiction_object.id == this.collectionObject.id
        })

        depictionsRemovedDuplicate.forEach(depiction => {
          if(!coDepictions.find(item => { return item.image_id == depiction.image_id })) {
            this.saveDepiction(co.id, depiction)
          }
        })
      },
      saveDepiction(coId, depiction) {
        let newDepiction = {
          depiction_object_id: coId,
          depiction_object_type: 'CollectionObject',
          image_id: depiction.image_id
        }
        CreateDepiction(newDepiction).then(createdDepiction => {
          this.depictions.push(createdDepiction)
        })
      },
      createDepictionForAll(depiction) {
        let coIds = this.collectionObjects.map((co) => { return co.id }).filter(id => { return this.collectionObject.id != id })
        this.depictions.push(depiction)
        coIds.forEach((id) => {
          this.saveDepiction(id, depiction)
        })
      },
      removeAllDepictionsByImageId(depiction) {
        this.$store.dispatch(ActionNames.RemoveDepictionsByImageId, depiction)
      }
    }
  }
</script>