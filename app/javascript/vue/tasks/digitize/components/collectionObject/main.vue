<template>
  <div>
    <block-layout>
      <div slot="header">
        <h3>Collection Objects</h3>
      </div>
      <div slot="options">
        <radial-annotator 
          v-if="collectionObject.id"
          :global-id="collectionObject.global_id"/>
      </div>
      <div slot="body">
        <div
          class="horizontal-left-content align-start">
          <div class="separate-right">
            <catalog-number/>
          </div>
          <div class="separate-left separate-right">
            <bioclassification/>
            <table-collection-objects/>
            <button 
              type="button"
              :disabled="!collectionObjects.length"
              class="button normal-input button-default"
              @click="newCO">Make New CO</button>
          </div>
          <div class="separate-left">
            <repository-component/>
          </div>
        </div>
        <buffered-component/>
        <depictions-component
          :object-value="collectionObject"
          :get-depictions="GetCollectionObjectDepictions"
          object-type="CollectionObject"
          default-message="Drop images here to add collection object figures"
          action-save="SaveCollectionObject"/>
      </div>
    </block-layout>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import TableCollectionObjects from './tableCollectionObjects.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from '../shared/depictions.vue'
  import RepositoryComponent from './repository.vue'
  import { GetterNames } from '../../store/getters/getters'
  import { ActionNames } from '../../store/actions/actions'
  import BlockLayout from '../../../../components/blockLayout.vue'
  import RadialAnnotator from '../../../../components/annotator/annotator.vue'
  import { GetCollectionObjectDepictions } from '../../request/resources.js'

  export default {
    components: {
      CatalogNumber,
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
      }
    },
    data() {
      return {
        types: [],
        labelRepository: undefined,
        labelEvent: undefined,
        GetCollectionObjectDepictions
      }
    },
    methods: {
      newCO() {
        this.$store.dispatch(ActionNames.NewCollectionObject)
      }
    }
  }
</script>