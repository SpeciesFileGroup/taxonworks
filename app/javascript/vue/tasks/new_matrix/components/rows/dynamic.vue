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
        v-if="componentExist"
        @send="create"
        :list="selectorLists[view]"
        :is="view + 'Component'"/>
    </div>
  </div>
</template>
<script>

import smartSelector from '../shared/smartSelector'
import searchComponent from './search'
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
    searchComponent
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
      smartOptions: ['quick', 'recent', 'pinboard', 'tag'],
      selectorLists: undefined,
      view: undefined
    }
  },
  mounted() {
    GetSmartSelector('keywords').then(response => {
      this.smartOptions = this.smartOptions.filter(value => Object.keys(response).includes(value))
      this.selectorLists = response
    })
  },
  methods: {
    create(item) {
      let data = {
        controlled_vocabulary_term_id: item.id,
        observation_matrix_id: this.matrixId,
        type: 'ObservationMatrixRowItem::TaggedRowItem'
      }
      this.$store.dispatch(ActionNames.CreateRowItem, data)
    }
  }
}
</script>
