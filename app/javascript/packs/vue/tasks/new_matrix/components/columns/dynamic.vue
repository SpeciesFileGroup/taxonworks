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
        @send="create"
        :list="selectorLists[view]"
        :is="view + 'Component'"/>
    </div>
  </div>
</template>
<script>

import smartSelector from '../shared/smartSelector'
//import searchComponent from './search'
import { 
  default as quickComponent, 
  default as recentComponent, 
  default as pinboardComponent 
} from '../shared/tag_list'
import { GetSmartSelector } from '../../request/resources'
import { ActionNames } from '../../store/actions/actions';
import { GetterNames } from '../../store/getters/getters'


export default {
  components: {
    smartSelector,
    quickComponent,
    recentComponent,
    pinboardComponent,
  },
  computed: {
    componentExist() {
      return this.$options.components[this.view + 'Component']
    },
    matrixId() {
      return this.$store.getters[GetterNames.GetMatrix].id
    }
  },
  data() {
    return {
      smartOptions: [],
      moreOptions: ['search'],
      selectorLists: undefined,
      view: undefined
    }
  },
  mounted() {
    GetSmartSelector('keywords').then(response => {
      this.smartOptions = Object.keys(response)
      this.selectorLists = response
    })
  },
  methods: {
    create(item) {
      let data = {
        controlled_vocabulary_term_id: item.id,
        observation_matrix_id: this.matrixId,
        type: 'ObservationMatrixColumnItem::TaggedColumnItem'
      }
      this.$store.dispatch(ActionNames.CreateColumnItem, data)
    }
  }
}
</script>
