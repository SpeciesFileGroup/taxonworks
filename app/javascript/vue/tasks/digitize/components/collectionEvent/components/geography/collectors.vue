<template>
  <div>
    <h2>Collectors</h2>
    <smart-selector
      v-model="view"
      name="collectors"
      :options="options"/>
    <autocomplete
      url="/url"
      placeholder="Search"
      min="2"
      label="label_html"
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
