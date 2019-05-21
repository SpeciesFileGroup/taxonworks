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
    <ul v-if="isList">
      <li v-for="item in list">
        <label>
          <input type="radio">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
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
  isList() {
    return Object.keys(this.lists).includes(this.view)
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
          url: '/extracts/autocomplete'
        },
        Otu: {
          url: '/otus/autocomplete'
        }
      }
    }
  }
}
</script>
