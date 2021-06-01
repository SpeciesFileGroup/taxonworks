<template>
  <div class="panel basic-information separate-top">
    <div class="header">
      <h3>Columns</h3>
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
        :batch-type="view"
        :matrix-id="matrix.id"
        :list="lists[view]"
        type="descriptor"
        @close="view = undefined"/>
    </div>
  </div>
</template>
<script>

  import { GetMatrixColumnMetadata } from '../../request/resources'
  import SmartSelector from '../shared/smartSelector.vue'
  import pinboardComponent from './batchView.vue'
  import keywordsComponent from './keywordView.vue'
  import searchComponent from './search.vue'
  import FromAnotherMatrixComponent from './copyDescriptors'
  import { GetterNames } from '../../store/getters/getters'

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
      GetMatrixColumnMetadata().then(response => {
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