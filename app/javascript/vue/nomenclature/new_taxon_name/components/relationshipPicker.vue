<template>
  <form class="panel basic-information">
    <a
      name="relationship"
      class="anchor"/>
    <div
      class="header flex-separate middle"
      :class="{ 'validation-warning' : softValidation.taxonRelationshipList.list.length }">
      <h3
      v-help.section.relationship.container
      >Relationship</h3>
      <expand
        @changed="expanded = !expanded"
        :expanded="expanded"/>
    </div>
    <div
      class="body"
      v-if="expanded">
      <div v-if="!taxonRelation">
        <hard-validation field="object_taxon_name_id">
          <autocomplete
            slot="body"
            url="/taxon_names/autocomplete"
            label="label_html"
            min="2"
            v-model="taxonRelation"
            event-send="autocompleteTaxonRelationshipSelected"
            placeholder="Search taxon name for the new relationship..."
            :add-params="{ type: 'Protonym', 'nomenclature_group[]': getRankGroup }"
            param="term"/>
        </hard-validation>
      </div>
      <div v-else>
        <tree-display
          :tree-list="treeList"
          :parent="parent"
          :object-lists="objectLists"
          :show-modal="showModal"
          mutation-name-add="AddTaxonRelationship"
          mutation-name-modal="SetModalRelationship"
          name-module="Relationship"
          display-name="subject_status_tag"/>
        <div class="switch-radio">
          <input
            name="relationship-picker-options"
            id="relationship-picker-common"
            checked
            type="radio"
            class="normal-input button-active"
            @click="showAdvance = false">
          <label for="relationship-picker-common">Common</label>
          <input
            name="relationship-picker-options"
            id="relationship-picker-advanced"
            type="radio"
            class="normal-input"
            @click="showAdvance = true">
          <label for="relationship-picker-advanced">Advanced</label>
          <input
            name="relationship-picker-options"
            id="relationship-picker-showall"
            type="radio"
            class="normal-input"
            @click="activeModal(true)">
          <label for="relationship-picker-showall">Show all</label>
        </div>
        <p class="inline">
          <span v-html="taxonRelation.label_html"/>
          <span
            type="button"
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="taxonRelation = undefined"/>
        </p>
        <div class="separate-top">
          <autocomplete
            v-if="showAdvance"
            :array-list="objectLists.allList"
            label="subject_status_tag"
            min="3"
            time="0"
            placeholder="Search"
            event-send="autocompleteRelationshipSelected"
            @getItem="addEntry"
            param="term"/>
          <list-common
            v-if="!showAdvance"
            :object-lists="objectLists.commonList"
            @addEntry="addEntry"
            display="subject_status_tag"
            :list-created="GetRelationshipsCreated"/>
        </div>
      </div>
      <list-entrys
        @update="loadTaxonRelationships"
        @addCitation="setRelationship"
        @delete="removeRelationship"
        :list="GetRelationshipsCreated"
        :display="['subject_status_tag', { link: '/tasks/nomenclature/browse/', label: 'object_object_tag', param: 'object_taxon_name_id'}]"/>
    </div>
  </form>
</template>
<script>

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import TreeDisplay from './treeDisplay.vue'
import ListEntrys from './listEntrys.vue'
import ListCommon from './commonList.vue'
import Expand from './expand.vue'
import Autocomplete from 'components/autocomplete.vue'
import HardValidation from './hardValidation.vue'
import getRankGroup from '../helpers/getRankGroup'

export default {
  components: {
    ListEntrys,
    Autocomplete,
    Expand,
    TreeDisplay,
    ListCommon,
    HardValidation
  },
  computed: {
    treeList () {
      return this.$store.getters[GetterNames.GetRelationshipList]
    },
    getRankGroup () {
      return getRankGroup(this.$store.getters[GetterNames.GetTaxon].rank_string)
    },
    GetRelationshipsCreated () {
      return this.$store.getters[GetterNames.GetTaxonRelationshipList].filter(function (item) {
        return (item.type.split('::')[1] != 'OriginalCombination' && item.type.split('::')[1] != 'Typification')
      })
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation]
    },
    taxonRelation: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonRelationship]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonRelationship, value)
      }
    },
    nomenclaturalCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
    },
    showModal () {
      return this.$store.getters[GetterNames.ActiveModalRelationship]
    }
  },
  data: function () {
    return {
      objectLists: this.makeLists(),
      expanded: true,
      showAdvance: false
    }
  },
  watch: {
    parent: {
      handler: function (newVal) {
        if (newVal == null) return true
        this.refresh()
      },
      immediate: true
    }
  },
  methods: {
    loadTaxonRelationships: function () {
      this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
    },
    removeRelationship: function (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item)
    },
    setRelationship (item) {
      this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item)
    },
    refresh: function () {
      let copyList = Object.assign({}, this.treeList[this.nomenclaturalCode])
      this.objectLists.tree = Object.assign({}, copyList.tree)
      this.objectLists.commonList = Object.assign({}, copyList.common)
      this.objectLists.allList = Object.assign({}, copyList.all)
      this.addType(this.objectLists.allList)
      this.objectLists.allList = Object.keys(this.objectLists.allList).map(key => this.objectLists.allList[key])
      this.getTreeList(this.objectLists.tree, copyList.all)
      this.addType(this.objectLists.commonList)
    },
    activeModal: function (value) {
      this.$store.commit(MutationNames.SetModalRelationship, value)
    },
    makeLists: function () {
      return {
        tree: undefined,
        commonList: [],
        allList: []
      }
    },
    filterAlreadyPicked: function (list, type) {
      return list.find(function (item) {
        return (item.type == type)
      })
    },
    addEntry: function (item) {
      this.$store.dispatch(ActionNames.AddTaxonRelationship, item)
    },
    getTreeList (list, ranksList) {
      for (var key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { value: key })
          Object.defineProperty(list[key], 'object_status_tag', { value: ranksList[key].object_status_tag })
          Object.defineProperty(list[key], 'subject_status_tag', { value: ranksList[key].subject_status_tag })
        }
        this.getTreeList(list[key], ranksList)
      }
    },
    addType (list) {
      for (var key in list) {
        Object.defineProperty(list[key], 'type', { value: key })
      }
    }
  }
}
</script>
