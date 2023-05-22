<template>
  <FacetContainer>
    <h3>In relationship</h3>
    <smart-selector
      class="separate-bottom"
      :options="options"
      v-model="view"
    />
    <div class="separate-top">
      <tree-display
        v-if="view == smartOptions.all"
        @close="view = smartOptions.common"
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
          :key="key"
        >
          <li v-if="!filterAlreadyPicked(item.type)">
            <label>
              <input
                :value="key"
                @click="addRelationship(item)"
                type="radio"
              >
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
        @get-item="addRelationship"
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
      @delete="removeItem"
    />
  </FacetContainer>
</template>

<script>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
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
    DisplayList,
    FacetContainer
  },

  props: {
    modelValue: {
      type: Object,
      default: () => ({})
    }
  },

  emits: ['update:modelValue'],

  computed: {
    smartOptions () {
      return OPTIONS
    },

    params: {
      get () {
        return this.modelValue
      },

      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    nomenclatureCode () {
      return this.modelValue.nomenclature_code
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
      if (newVal.taxon_name_relationship_type?.length || !this.relationshipSelected.length) return
      this.relationshipSelected = []
    },

    relationshipSelected: {
      handler (newVal) {
        this.params.taxon_name_relationship_type = newVal.map(relationship => relationship.type)
      },
      deep: true
    },

    nomenclatureCode: {
      handler () {
        if (this.relationshipsList.length) {
          this.merge()
        }
      }
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
      const relationshipsList = JSON.parse(JSON.stringify(this.relationshipsList))
      const newList = {
        all: {},
        common: {},
        tree: {}
      }
      const nomenclatureCodes = this.nomenclatureCode
        ? [this.nomenclatureCode.toLowerCase()]
        : Object.keys(relationshipsList)

      nomenclatureCodes.forEach(key => {
        newList.all = Object.assign(newList.all, relationshipsList[key].all)
        newList.tree = Object.assign(newList.tree, relationshipsList[key].tree)
        for (const keyType in relationshipsList[key].common) {
          relationshipsList[key].common[keyType].name = `${relationshipsList[key].common[keyType].subject_status_tag} (${key})`
          relationshipsList[key].common[keyType].type = keyType
        }
        newList.common = Object.assign(newList.common, relationshipsList[key].common)
      })
      this.getTreeList(newList.tree, newList.all)
      this.mergeLists = newList
    },

    getTreeList (list, ranksList) {
      for (const key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { writable: true, value: key })
          Object.defineProperty(list[key], 'name', { writable: true, value: ranksList[key].subject_status_tag })
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
