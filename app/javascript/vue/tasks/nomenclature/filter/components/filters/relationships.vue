<template>
  <div>
    <h3>Relationships</h3>
    <smart-selector
      v-if="taxon"
      class="separate-bottom"
      :options="options"
      v-model="view" 
    />
    <div>
      <template>
        <div
          v-if="taxon"
          class="horizontal-left-content">
          <span v-html="taxon.label"/>
          <span
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="taxon = undefined"/>
        </div>
        <autocomplete
          v-else
          placeholder="Select a taxon name for the relationship"
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          :clear-after="true"
          @getItem="setTaxon"/>
      </template>
    </div>
    <div
      class="separate-top"
      v-if="taxon">
      <tree-display
        v-if="view == smartOptions.all"
        @close="view = undefined"
        :object-lists="mergeLists"
        modal-title="Relationships"
        :display="display"
        @selected="addRelationshipType"
      />
      <ul
        v-if="view == smartOptions.common"
        class="no_bullets"
      >
        <li
          v-for="(item, key) in mergeLists.common"
          :key="key">
          <label>
            <input
              :value="key"
              @click="item.type = key; addRelationshipType(item)"
              type="radio">
            {{ item[display] }}
          </label>
        </li>
      </ul>
      <autocomplete
        v-if="view == smartOptions.advanced"
        url=""
        :array-list="Object.keys(mergeLists.all).map(key => { mergeLists.all[key].type = key; return mergeLists.all[key] })"
        :label="display"
        :clear-after="true"
        min="3"
        time="0"
        @getItem="addRelationshipType"
        placeholder="Search"
        event-send="autocompleteRelationshipSelected"
        param="term" 
      />
    </div>
    <list-component
      :list="relationships"
      @flip="flipRelationship"
      @delete="removeItem"/>
  </div>
</template>

<script>

import SmartSelector from 'components/switch'
import TreeDisplay from '../treeDisplay'
import Autocomplete from 'components/ui/Autocomplete'
import ListComponent from '../relationshipsList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName, TaxonNameRelationship } from 'routes/endpoints'

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
    ListComponent
  },
  props: {
    value: {

    }
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
      paramRelationships: undefined,
      view: OPTIONS.common,
      relationshipsList: {},
      mergeLists: {},
      showAll: false,
      relationships: [],
      taxon: undefined,
      display: 'subject_status_tag',
      types: [
        {
          label: 'as subject',
          value: 'subject_status_tag'
        },
        {
          label: 'as object',
          value: 'object_status_tag'
        }
      ],
      typeSelected: undefined
    }
  },
  watch: {
    value(newVal) {
      if(newVal.length || !this.relationships.length) return
      this.taxon = undefined,
      this.typeSelected = undefined,
      this.relationships = []
    },
    relationships() {
      let newList = this.relationships.map(item => {
        let name = item.type_name == 'subject_status_tag' ? 'subject_taxon_name_id' : 'object_taxon_name_id'
        return {
          type: item.type,
          [name]: item.taxonId
        }
      })
      this.$emit('input', newList)
    }
  },
  mounted () {
    TaxonNameRelationship.types().then(response => {
      this.relationshipsList = response.body
      this.merge()

      const params = URLParamsToJSON(location.href)

      if (params.taxon_name_relationship) {
        Object.values(params.taxon_name_relationship).forEach(relationship => {
          const isSubject = relationship.hasOwnProperty('subject_taxon_name_id')
          const typeName = (isSubject ? 'subject_status_tag' : 'object_status_tag')
          const taxonId = relationship[(isSubject ? 'subject_taxon_name_id' : 'object_taxon_name_id')]
          TaxonName.find(taxonId).then(taxon => {
            this.relationships.push(
              {
                type_object: this.mergeLists.all[relationship.type],
                type: relationship.type,
                taxon_label: taxon.body.name,
                type_label: this.mergeLists.all[relationship.type][(isSubject ? 'subject_status_tag' : 'object_status_tag')],
                type_name: typeName,
                taxonId: taxonId
              }
            )
          })
        })
      }
    })
  },
  methods: {
    merge () {
      let nomenclatureCodes = Object.keys(this.relationshipsList)
      let newList = {
        all: {},
        common: {},
        tree: {}
      }
      nomenclatureCodes.forEach(key => {
        newList.all = Object.assign(newList.all, this.relationshipsList[key].all)
        newList.tree = Object.assign(newList.tree, this.relationshipsList[key].tree)
        for (var keyType in this.relationshipsList[key].common) {
          this.relationshipsList[key].common[keyType].subject_status_tag = `${this.relationshipsList[key].common[keyType].subject_status_tag} (${key})`
        }
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
    addRelationshipType(relationship) {
      this.view = undefined
      this.typeSelected = relationship
      this.addRelationship()
    },
    setTaxon(taxon) {
      this.taxon = taxon
    },
    addRelationship() {
      this.relationships.push( 
        { 
          type_object: this.typeSelected,
          type: this.typeSelected.type,
          taxon_label: this.taxon.label, 
          type_label: this.typeSelected[this.display],
          type_name: this.display,
          taxonId: this.taxon.id,
        }
      )
      this.typeSelected = undefined
      this.taxon = undefined
      this.view = OPTIONS.common
    },
    removeItem(key) {
      this.$delete(this.relationships, key)
    },
    flipRelationship(relationship) {
      let index = this.relationships.findIndex(item => {
        return item.type == relationship.type && item.type_name == relationship.type_name
      })
      let flipType = (relationship.type_name == 'subject_status_tag' ? 'object_status_tag' : 'subject_status_tag')
      relationship.type_name = flipType
      relationship.type_label = relationship.type_object[flipType]
      this.$set(this.relationships, index, relationship)
    }
  }
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%;
}

.type-list {
  min-width: 84px;
}
</style>
