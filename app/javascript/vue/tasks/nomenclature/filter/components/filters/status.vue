<template>
  <div>
    <h3>Status</h3>
    <smart-selector
      class="separate-bottom"
      :options="options"
      v-model="view" 
    />
    <div class="separate-top">
      <tree-display
        v-if="view == smartOptions.all"
        @close="view = undefined"
        :object-lists="mergeLists"
        modal-title="Relationships"
        display="name"
        @selected="addStatus"
      />
      <ul
        v-if="view == smartOptions.common"
        class="no_bullets"
      >
        <template
          v-for="(item, key) in mergeLists.common"
          :key="key">
          <li v-if="!filterAlreadyPicked(item.type)">
            <label>
              <input
                :value="key"
                @click="addStatus(item)"
                type="radio">
              {{ item.name }}
            </label>
          </li>
        </template>
      </ul>
      <autocomplete
        v-if="view == smartOptions.advanced"
        url=""
        :array-list="Object.keys(mergeLists.all).map(key => mergeLists.all[key])"
        label="name"
        :clear-after="true"
        min="3"
        time="0"
        @getItem="addStatus"
        placeholder="Search"
        event-send="autocompleteRelationshipSelected"
        param="term" 
      />
    </div>
    <display-list
      label="name"
      set-key="type"
      :delete-warning="false"
      :list="statusSelected"
      @delete="removeItem"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TreeDisplay from '../treeDisplay'
import Autocomplete from 'components/ui/Autocomplete'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonNameClassification } from 'routes/endpoints'

const OPTIONS = {
  common: 'common',
  advanced: 'advanced',
  all: 'all'
}

export default {
  components: {
    SmartSelector,
    TreeDisplay,
    Autocomplete,
    DisplayList
  },

  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    smartOptions () {
      return OPTIONS
    }
  },

  data () {
    return {
      options: Object.values(OPTIONS),
      lists: [],
      paramRelationships: undefined,
      view: OPTIONS.common,
      statusList: {},
      statusSelected: [],
      mergeLists: {},
      relationships: [],
      typeSelected: undefined
    }
  },

  watch: {
    value (newVal) {
      if (newVal.length || !this.statusSelected.length) return
      this.statusSelected = []
    },

    statusSelected: {
      handler (newVal) {
        this.$emit('update:modelValue', newVal.map(status => status.type))
      },
      deep: true
    }
  },

  created () {
    TaxonNameClassification.types().then(response => {
      this.statusList = response.body
      this.merge()

      const params = URLParamsToJSON(location.href)
      if (params.taxon_name_classification) {
        params.taxon_name_classification.forEach(classification => {
          this.addStatus(this.mergeLists.all[classification])
        })
      }
    })
  },

  methods: {
    merge () {
      const nomenclatureCodes = Object.keys(this.statusList)
      const newList = {
        all: {},
        common: {},
        tree: {}
      }
      nomenclatureCodes.forEach(key => {
        newList.all = Object.assign(newList.all, this.statusList[key].all)
        newList.tree = Object.assign(newList.tree, this.statusList[key].tree)
        for (var keyType in this.statusList[key].common) {
          this.statusList[key].common[keyType].name = `${this.statusList[key].common[keyType].name} (${key})`
        }
        newList.common = Object.assign(newList.common, this.statusList[key].common)
      })
      this.getTreeList(newList.tree, newList.all)
      this.mergeLists = newList
    },

    getTreeList (list, ranksList) {
      for (var key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { writable: true, value: key })
          Object.defineProperty(list[key], 'name', { writable: true, value: ranksList[key].name })
        }
        this.getTreeList(list[key], ranksList)
      }
    },

    removeItem (status) {
      this.statusSelected.splice(this.statusSelected.findIndex(item => item.type === status.type),1)
    },

    addStatus (item) {
      this.statusSelected.push(item)
      this.view = OPTIONS.common
    },

    filterAlreadyPicked (type) {
      return this.statusSelected.find(item => item.type === type)
    }
  }
}
</script>
