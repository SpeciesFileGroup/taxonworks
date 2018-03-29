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
        :is="view + 'Component'"/>
    </div>
  </div>
</template>
<script>

import smartSelector from './smartSelector'
import searchComponent from './search'

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
      smartOptions: ['quick', 'recent', 'search'],
      view: undefined
    }
  }
}
</script>
