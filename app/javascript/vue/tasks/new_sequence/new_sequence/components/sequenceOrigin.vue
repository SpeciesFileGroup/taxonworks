<template>
  <div>
    <h2>Sequence origin</h2>
    <ul class="no_bullets context-menu">
      <li
        v-for="(item, key) in types"
        :key="key">
        <label>
          <input
            v-model="type"
            :value="key"
            type="radio">
          {{ key }}
        </label>
      </li>
    </ul>
    <smart-selector
      class="separate-top separate-bottom"
      v-model="view"
      :options="tabs"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import Autocomplete from 'components/autocomplete'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  data () {
    return {
      type: undefined,
      lists: [],
      tabs: ['search'],
      view: undefined,
      types: {
        CollectionObject: {
          url: '/collection_objects/autocomplete'
        },
        Extract: {

        },
        Otu: {
          url: '/otus/autocomplete'
        }
      }
    }
  }
}
</script>
