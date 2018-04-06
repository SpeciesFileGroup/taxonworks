<template>
  <div class="panel basic-information separate-top">
    <div class="header">
      <h3>Rows</h3>
    </div>
    <div class="body">
      <smart-selector
        :options="smartOptions"
        v-model="view"
        name="rows-smart"/>
      <component
        v-if="lists[view]"
        :is="view + 'Component'"
        :batch-type="view"
        :list="lists[view]"/>
    </div>
  </div>
</template>
<script>

  import { GetMatrixRowMetadata } from '../../request/resources'
  import SmartSelector from '../shared/smartSelector.vue'
  import pinboardComponent from './batchView.vue'
  import keywordsComponent from './keywordView.vue'

  export default {
    components: {
      keywordsComponent,
      pinboardComponent,
      SmartSelector
    },
    data() {
      return {  
        view: undefined,
        smartOptions: [],
        lists: []
      }
    },
    mounted() {
      GetMatrixRowMetadata().then(response => {
        this.smartOptions = Object.keys(response)
        this.lists = response
      })
    }
  }
</script>