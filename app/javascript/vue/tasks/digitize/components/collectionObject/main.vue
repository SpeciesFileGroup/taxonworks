<template>
  <div>
    <div class="horizontal-left-content align-start">
      <div>
        <catalog-number/>
      </div>
      <div>
        <bioclassification/>
      </div>
      <div>
        <repository-component/>
      </div>
    </div>
    <buffered-component/>
    <depictions-component
      :object-value="collectionObject"
      object-type="CollectionObject"
      action-save="SaveCollectionObject"/>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from '../shared/depictions.vue'
  import RepositoryComponent from './repository.vue'
  import { GetterNames } from '../../store/getters/getters';

  export default {
    components: {
      CatalogNumber,
      Bioclassification,
      BufferedComponent,
      DepictionsComponent,
      RepositoryComponent
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