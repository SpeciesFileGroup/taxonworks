<template>
  <div>
    <h2>Collectors</h2>
    <smart-selector
      v-model="view"
      :options="options"/>
    <autocomplete
      url="/url"
      placeholder="Search"
      param="term"/>
  </div>
</template>

<script>

import SmartSelector from '../../../../../../components/switch.vue'
import Autocomplete from '../../../../../../components/autocomplete.vue'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  data() {
    return {
      options: ['Quick', 'Recent', 'Pinboard', 'Search', 'New'],
      view: undefined
    }
  }
}
</script>

<style>

</style>
