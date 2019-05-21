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
    <ul
      class="no_bullets"
      v-if="isList">
      <li v-for="item in list[view]">
        <label>
          <input type="radio">
          <span v-html="item.object_tag"/>
        </label>
      </li>
    </ul>
    <autocomplete
      v-else
      :url="types[type].url"
      param="term"
      label="label_html"
      @getItem="selected.push($event)"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import Autocomplete from 'components/autocomplete'

import { GetOtuSmartSelector, GetCollectionObjectSmartSelector, GetExtractSmartSelector } from '../request/resources'

export default {
  components: {
    SmartSelector,
    Autocomplete
  },
  computed: {
    isList() {
      return Object.keys(this.lists).includes(this.view)
    }
  },
  data () {
    return {
      type: 'CollectionObject',
      lists: [],
      tabs: ['search'],
      view: undefined,
      selected: [],
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
  },
  watch: {
    type(newVal) {
      switch(newVal) {
        case 'CollectionObject':
          GetOtuSmartSelector().then(response => {
            this.setSmartLists(response.body)
          })
          break;
        case 'Extract':
          GetExtractSmartSelector().then(response => {
            this.setSmartLists(response.body)
          })
          break;
        case 'Otu':
          GetOtuSmartSelector().then(response => {
            this.setSmartLists(response.body)
          })
          break;
      }
    }
  },
  methods: {
    setSmartLists(lists) {
      this.lists = lists
      this.tabs = Object.keys(lists)
      this.tabs.push('search')
    }
  }
}
</script>
