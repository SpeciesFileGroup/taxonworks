<template>
  <div class="flexbox align-start">
    <block-layout class="separate-right">
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
        <buffered-component class="separate-top"/>
        <depictions-component
          class="separate-top"
          :object-value="collectionObject"
          :get-depictions="GetCollectionObjectDepictions"
          object-type="CollectionObject"
          @create="createDepictionForAll"
          @delete="removeAllDepictionsByImageId"
          default-message="Drop images here to add collection object figures"
          action-save="SaveCollectionObject"/>
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
  import { GetCollectionObjectDepictions, CreateDepiction } from '../../request/resources.js'

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
      RadialAnnotator
    },
    computed: {
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