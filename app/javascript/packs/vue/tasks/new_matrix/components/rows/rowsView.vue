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
        :list="selectorLists[view]"
        :is="view + 'Component'"/>
    </div>
  </div>
</template>
<script>

import smartSelector from '../shared/smartSelector'
import searchComponent from './search'
import { GetSmartSelector } from '../../request/resources'

export default {
  components: {
    smartSelector,
    searchComponent
  },
  computed: {
    componentExist() {
      return this.$options.components[this.view + 'Component']
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
}
</script>
