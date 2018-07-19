<template>
  <div>
    <div class="horizontal-left-content">
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
    <depictions-component/>
  </div>
</template>

<script>

  import CatalogNumber from './catalogNumber.vue'
  import Bioclassification from './bioclassification.vue'
  import BufferedComponent from './bufferedData.vue'
  import DepictionsComponent from './depictions.vue'
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
    data() {
      return {
        types: [],
        labelRepository: undefined,
        labelEvent: undefined
      }
    }
  }
</script>