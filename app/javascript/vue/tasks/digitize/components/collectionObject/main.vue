<template>
  <div>
    <block-layout>
      <div slot="header">
        <h3>Collection Object</h3>
      </div>
      <div
        class="horizontal-left-content align-start"
        slot="body">
        <div class="separate-right">
          <catalog-number/>
        </div>
        <div class="separate-left separate-right">
          <bioclassification/>
        </div>
        <div class="separate-left">
          <repository-component/>
        </div>
      </div>
      <buffered-component/>
      <depictions-component
        :object-value="collectionObject"
        object-type="CollectionObject"
        action-save="SaveCollectionObject"/>
    </block-layout>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from '../shared/depictions.vue'
  import RepositoryComponent from './repository.vue'
  import { GetterNames } from '../../store/getters/getters';
  import BlockLayout from '../../../../components/blockLayout.vue'

  export default {
    components: {
      CatalogNumber,
      Bioclassification,
      BufferedComponent,
      DepictionsComponent,
      RepositoryComponent,
      BlockLayout
    },
    computed: {
      collectionObject () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
    },
    data() {
      return {
        types: [],
        labelRepository: undefined,
        labelEvent: undefined
      }
    }
  }
</script>