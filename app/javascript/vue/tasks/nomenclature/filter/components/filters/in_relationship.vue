<template>
  <div>
    <h3>In relationship</h3>
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
        @selected="addRelationship"
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
                @click="addRelationship(item)"
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
        clear-after
        min="3"
        time="0"
        @getItem="addRelationship"
        placeholder="Search"
        event-send="autocompleteRelationshipSelected"
        param="term"
      />
    </div>
    <display-list
      label="name"
      set-key="type"
      :delete-warning="false"
      :list="relationshipSelected"
      @delete="removeItem"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TreeDisplay from '../treeDisplay'
import Autocomplete from 'components/ui/Autocomplete'
import DisplayList from 'components/displayList.vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonNameRelationship } from 'routes/endpoints'

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

    }
  },

  emits: ['update:modelValue'],

  computed: {
    smartOptions() {
      return OPTIONS
    }
  },

  data () {
    return {
      options: Object.values(OPTIONS),
      lists: [],
      paramRelationships: undefined,
      view: OPTIONS.common,
      relationshipsList: {},
      relationshipSelected: [],
      mergeLists: {},
      relationships: [],
      typeSelected: undefined
    }
  },

  watch: {
    modelValue (newVal) {
      if (newVal.length || !this.relationshipSelected.length) return
      this.relationshipSelected = []
    },
    relationshipSelected (newVal) {
      this.$emit('update:modelValue', newVal.map(relationship => relationship.type))
    }
  },

  created () {
    TaxonNameRelationship.types().then(response => {
      this.relationshipsList = response.body
      this.merge()

      const params = URLParamsToJSON(location.href)
      if (params.taxon_name_relationship_type) {
        params.taxon_name_relationship_type.forEach(type => {
          const data = this.mergeLists.all[type]
          data.type = type
          data.name = this.mergeLists.all[type].subject_status_tag
          this.addRelationship(data)
        })
      }
    })
  },

  methods: {
    merge () {
      const nomenclatureCodes = Object.keys(this.relationshipsList)
      const newList = {
        all: {},
        common: {},
        tree: {}
      }
      nomenclatureCodes.forEach(key => {
        newList.all = Object.assign(newList.all, this.relationshipsList[key].all)
        newList.tree = Object.assign(newList.tree, this.relationshipsList[key].tree)
        for (var keyType in this.relationshipsList[key].common) {
          this.relationshipsList[key].common[keyType].name = `${this.relationshipsList[key].common[keyType].subject_status_tag} (${key})`
          this.relationshipsList[key].common[keyType].type = keyType
        }
        newList.common = Object.assign(newList.common, this.relationshipsList[key].common)
      })
      this.getTreeList(newList.tree, newList.all)
      this.mergeLists = newList
    },

    getTreeList (list, ranksList) {
      for (const key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { value: key })
          Object.defineProperty(list[key], 'name', { value: ranksList[key].subject_status_tag })
        }
        this.getTreeList(list[key], ranksList)
      }
    },

    removeItem (relationship) {
      this.relationshipSelected.splice(this.relationshipSelected.findIndex(item => item.type === relationship.type), 1)
    },

    addRelationship (item) {
      this.relationshipSelected.push(item)
      this.view = OPTIONS.common
    },

    filterAlreadyPicked (type) {
      return this.relationshipSelected.find(item => item.type === type)
    }
  }
}
</script>