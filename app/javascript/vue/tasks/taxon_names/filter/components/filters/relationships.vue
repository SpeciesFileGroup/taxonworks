<template>
  <div>
    <h2>Relationships</h2>
    <smart-selector
      class="separate-bottom"
      :options="options"
      v-model="view" 
    />
    <tree-display
      v-if="view == smartOptions.all"
      @close="view = smartOptions.common"
      :object-lists="mergeLists"
      modal-title="Relationships"
      display="subject_status_tag" 
    />
    <ul
      v-if="view == smartOptions.common"
      class="no_bullets"
    >
      <li v-for="item in mergeLists.common">
        <label>
          <input type="radio">
          {{ item.object_status_tag }}
        </label>
      </li>
    </ul>
    <autocomplete
      v-if="view == smartOptions.advanced"
      url=""
      :array-list="Object.keys(mergeLists.all).map(key => mergeLists.all[key])"
      label="subject_status_tag"
      :clear-after="true"
      min="3"
      time="0"
      placeholder="Search"
      event-send="autocompleteRelationshipSelected"
      param="term" 
    />
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TreeDisplay from '../treeDisplay'
import { GetRelationshipsMetadata } from '../../request/resources.js'
import Autocomplete from 'components/autocomplete'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

export default {
  components: {
    SmartSelector,
    TreeDisplay,
    Autocomplete
  },
  computed: {
    smartOptions() {
      return OPTIONS
    }
  },
  data() {
    return {
      options: Object.values(OPTIONS),
      lists: [],
      view: undefined,
      relationshipsList: {},
      mergeLists: {},
      showAll: false,
    }
  },
  mounted() {
    GetRelationshipsMetadata().then(response => {
      this.relationshipsList = response.body
      this.merge()
    })
  },
  methods: {
    merge() {
      let nomenclatureCodes = Object.keys(this.relationshipsList)
      let newList = {
        all: {},
        common: {},
        tree: {}
      }
      nomenclatureCodes.forEach(key => {
        newList.all = Object.assign(newList.all, this.relationshipsList[key].all)
        newList.tree = Object.assign(newList.tree, this.relationshipsList[key].tree)
        newList.common = Object.assign(newList.common, this.relationshipsList[key].common)
      })
      this.getTreeList(newList.tree, newList.all)
      this.mergeLists = newList
    },
    getTreeList (list, ranksList) {
      for (var key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { value: key })
          Object.defineProperty(list[key], 'object_status_tag', { value: ranksList[key].object_status_tag })
          Object.defineProperty(list[key], 'subject_status_tag', { value: ranksList[key].subject_status_tag })
          Object.defineProperty(list[key], 'valid_subject_ranks', { value: ranksList[key].valid_subject_ranks })
        }
        this.getTreeList(list[key], ranksList)
      }
    },
  }
}
</script>
