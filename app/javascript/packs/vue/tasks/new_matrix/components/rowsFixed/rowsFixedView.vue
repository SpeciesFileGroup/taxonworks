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

import smartSelector from '../shared/smartSelector'
import pinboardComponent from './byPinboard.vue'
import objectComponent from './byObject.vue'

export default {
  components: {
    smartSelector,
    pinboardComponent,
    objectComponent
  },
  data() {
    return {
      smartOptions: ['Object', 'Tag', 'Pinboard'],
      view: undefined
    }
  }

}
</script>