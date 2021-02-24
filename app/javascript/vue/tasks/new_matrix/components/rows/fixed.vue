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
        :is="componentSelected"
        :matrix-id="matrix.id"
        :batch-type="view"
        :list="lists[view]"
        @close="view = undefined"/>
    </div>
  </div>
</template>
<script>

  import { GetMatrixRowMetadata } from '../../request/resources'
  import { GetterNames } from '../../store/getters/getters'
  import SmartSelector from '../shared/smartSelector.vue'
  import pinboardComponent from './batchView.vue'
  import keywordsComponent from './keywordView.vue'
  import searchComponent from './search.vue'
  import FromAnotherMatrixComponent from './copyRows'

  export default {
    components: {
      keywordsComponent,
      pinboardComponent,
      searchComponent,
      SmartSelector,
      FromAnotherMatrixComponent
    },
    computed: {
      componentSelected () {
        return this.removeSpaces(this.view + 'Component')
      },
      componentExist () {
        return this.$options.components[this.removeSpaces(this.view + 'Component')]
      },
      matrix () {
        return this.$store.getters[GetterNames.GetMatrix]
      }
    },
    data() {
      return {  
        view: undefined,
        smartOptions: [],
        moreOptions: ['search', 'From Another Matrix'],
        lists: []
      }
    },
    mounted() {
      GetMatrixRowMetadata().then(response => {
        this.smartOptions = Object.keys(response.body)
        this.lists = response.body
      })
    },
    methods: {
      removeSpaces(line) {
        return line.replace(/ /g, '')
      }
    }
  }
</script>