<template>
  <div class="panel basic-information separate-top">
    <div class="header">
      <h3>Rows</h3>
    </div>
    <div class="body">
      <smart-selector
        :options="smartOptions"
        :add-option="moreOptions"
        v-model="view"
        name="rows-smart"/>
      <component
        v-if="componentExist"
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
  import searchComponent from './search.vue'

  export default {
    components: {
      keywordsComponent,
      pinboardComponent,
      searchComponent,
      SmartSelector
    },
    computed: {
      componentExist() {
        return this.$options.components[this.view + 'Component']
      }
    },
    data() {
      return {  
        view: undefined,
        smartOptions: [],
        moreOptions: ['search'],
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