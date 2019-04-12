<template>
  <div>
    <h2>Relationships</h2>
    <smart-selector
      :options="options"
      v-model="view"/>
    <tree-display
      :object-lists="relationshipsList.tree"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TreeDisplay from '../treeDisplay'
import { GetRelationshipsMetadata } from '../../request/resources.js'

export default {
  components: {
    SmartSelector,
    TreeDisplay
  },
  data() {
    return {
      options: [],
      lists: [],
      view: undefined,
      relationshipsList: {

      }
    }
  },
  mounted() {
    GetRelationshipsMetadata().then(response => {
      this.relationshipsList = response.body
    })
  }
}
</script>

<style>

</style>
