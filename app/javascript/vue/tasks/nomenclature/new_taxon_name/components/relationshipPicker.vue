<template>
  <block-layout
    anchor="relationship"
    :warning="checkValidation"
    v-help.section.relationship.container>
    <h3 slot="header">Relationship</h3>
    <div
      slot="body">
      <div v-if="editMode">
        <p class="inline">
          <span class="separate-right">Editing relationship: </span>
          <span v-html="editMode.object_tag"/>
          <span
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="closeEdit"/>
        </p>
      </div>
      <div v-if="!taxonRelation">
        <div
          class="horizontal-left-content"
          slot="body">
          <autocomplete
            url="/taxon_names/autocomplete"
            label="label_html"
            min="2"
            @getItem="taxonRelation = $event"
            event-send="autocompleteTaxonRelationshipSelected"
            placeholder="Search taxon name for the new relationship..."
            :add-params="{ type: 'Protonym', 'nomenclature_group[]': getRankGroup }"
            param="term"/>
        </div>
      </div>
      <template v-else>
        <div v-if="isInsertaeSedis">
          <p class="inline">
            <span v-html="taxonLabel"/>
            <span
              type="button"
              title="Undo"
              class="circle-button button-default btn-undo"
              @click="taxonRelation = undefined"/>
          </p>
          <ul class="no_bullets">
            <li @click="addEntry(incertaeSedis[nomenclaturalCode])">
              <label>
                <input type="radio">
                Insertae sedis
              </label>
            </li>
          </ul>
        </div>
        <div v-else>
          <tree-display
            :tree-list="treeList"
            :parent="parent"
            :object-lists="objectLists"
            :show-modal="showModal"
            valid-property="valid_subject_ranks"
            @close="view = 'Common'"
            @selected="addEntry"
            mutation-name-add="AddTaxonRelationship"
            mutation-name-modal="SetModalRelationship"
            name-module="Relationship"
            display-name="subject_status_tag"/>

          <switch-component
            v-model="view"
            :options="tabs"/>
          <p class="inline">
            <span v-html="taxonLabel"/>
            <span
              type="button"
              title="Undo"
              class="circle-button button-default btn-undo"
              @click="taxonRelation = undefined"/>
          </p>
          <div class="separate-top">
            <autocomplete
              v-if="view === 'Advanced'"
              :array-list="objectLists.allList"
              label="subject_status_tag"
              min="3"
              time="0"
              placeholder="Search"
              event-send="autocompleteRelationshipSelected"
              @getItem="addEntry"
              param="term"/>
            <list-common
              v-else
              :object-lists="objectLists.commonList"
              @addEntry="addEntry"
              display="subject_status_tag"
              :list-created="GetRelationshipsCreated"/>
          </div>
        </div>
      </template>
      <list-entrys
        @update="loadTaxonRelationships"
        @addCitation="setRelationship"
        @delete="removeRelationship"
        :edit="true"
        @edit="editRelationship"
        :list="GetRelationshipsCreated"
        :display="['subject_status_tag', { link: '/tasks/nomenclature/browse?taxon_name_id=', label: 'object_object_tag', param: 'object_taxon_name_id'}]"/>
    </div>
  </block-layout>
</template>
<script>

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import TreeDisplay from './treeDisplay.vue'
import ListEntrys from './listEntrys.vue'
import ListCommon from './commonList.vue'
import Autocomplete from 'components/autocomplete.vue'
import getRankGroup from '../helpers/getRankGroup'
import SwitchComponent from 'components/switch'
import BlockLayout from './blockLayout'

export default {
  components: {
    ListEntrys,
    Autocomplete,
    TreeDisplay,
    ListCommon,
    SwitchComponent,
    BlockLayout
  },
  computed: {
    taxonLabel() {
      return this.taxonRelation.hasOwnProperty('label_html') ? this.taxonRelation.label_html : this.taxonRelation.object_tag
    },
    treeList () {
      return this.$store.getters[GetterNames.GetRelationshipList]
    },
    getRankGroup () {
      return getRankGroup(this.$store.getters[GetterNames.GetTaxon].rank_string)
    },
    GetRelationshipsCreated () {
      return this.$store.getters[GetterNames.GetTaxonRelationshipList].filter(function (item) {
        return (
          item.type.split('::')[1] !== 'OriginalCombination' &&
          item.type.split('::')[1] !== 'Typification' &&
          !item.type.endsWith('::UncertainPlacement') &&
          !item.type.endsWith('::SourceClassifiedAs'))
      })
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].taxonRelationshipList.list
    },
    checkValidation () {
      return this.softValidation?.find(item => this.GetRelationshipsCreated.find(created => created.global_id === item.global_id))
    },
    nomenclaturalCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
    },
    showModal () {
      return this.$store.getters[GetterNames.ActiveModalRelationship]
    }
  },
  data () {
    return {
      tabs: ['Common', 'Advanced', 'Show all'],
      view: 'Common',
      objectLists: this.makeLists(),
      taxonRelation: undefined,
      errors: undefined,
      showAdvance: false,
      editMode: undefined,
      lists: undefined,
      isInsertaeSedis: false,
      incertaeSedis: {
        iczn: { type: 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement' },
        icvcn: { type: 'TaxonNameRelationship::Icvcn::Accepting::UncertainPlacement' }
      }
    }
  },
  watch: {
    parent: {
      handler: function (newVal) {
        if (newVal == null) return true
        this.refresh()
      },
      immediate: true
    },
    view (newVal) {
      if (newVal === 'Show all') {
        this.activeModal(true)
      }
    }
  },
  methods: {
    setInsertaeSedis: function () {
      this.isInsertaeSedis = true
      this.taxonRelation = this.parent
    },
    loadTaxonRelationships: function () {
      this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
    },
    removeRelationship: function (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item).then(() => {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      })
    },
    setRelationship (item) {
      this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item)
    },
    refresh: function () {
      let copyList = Object.assign({}, this.treeList[this.nomenclaturalCode])
      this.objectLists.tree = Object.assign({}, JSON.parse(JSON.stringify(copyList.tree)))
      this.objectLists.commonList = Object.assign({}, JSON.parse(JSON.stringify(copyList.common)))
      this.objectLists.allList = Object.assign({}, JSON.parse(JSON.stringify(copyList.all)))
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
        allList: [],
      }
    },
    addEntry: function (item) {
      if(this.editMode) {
        let relationship = {
          id: this.editMode.id,
          subject_taxon_name_id: this.taxon.id,
          object_taxon_name_id: this.taxonRelation.hasOwnProperty('object_taxon_name_id') ? this.taxonRelation.object_taxon_name_id : this.taxonRelation.id,
          type: item.type
        }

        this.$store.dispatch(ActionNames.UpdateTaxonRelationship, relationship).then(() => {
          this.taxonRelation = undefined
          this.editMode = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      }
      else {
        this.$store.dispatch(ActionNames.AddTaxonRelationship, {
          type: item.type,
          taxonRelationshipId: this.taxonRelation.id
        }).then(() => {
          this.taxonRelation = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        }, (errors) => {})
      }
      this.isInsertaeSedis = false
    },
    closeEdit() {
      this.editMode = undefined
      this.taxonRelation = undefined
    },
    editRelationship(value) {
      this.taxonRelation = value
      this.editMode = this.taxonRelation
    },
    getTreeList (list, ranksList) {
      for (var key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { value: key })
          Object.defineProperty(list[key], 'object_status_tag', { value: ranksList[key].object_status_tag })
          Object.defineProperty(list[key], 'subject_status_tag', { value: ranksList[key].subject_status_tag })
          Object.defineProperty(list[key], 'valid_subject_ranks', { value: ranksList[key].valid_subject_ranks })
        }
        else {
          let label = key.split('::')

          Object.defineProperty(list[key], 'type', { value: key })
          Object.defineProperty(list[key], 'object_status_tag', { value: label[label.length-1].replace(/\.?([A-Z])/g, function (x,y){return " " + y.toLowerCase()}).replace(/^_/, "").toLowerCase().trim() })
          Object.defineProperty(list[key], 'subject_status_tag', { value: label[label.length-1].replace(/\.?([A-Z])/g, function (x,y){return " " + y.toLowerCase()}).replace(/^_/, "").toLowerCase().trim() })
          Object.defineProperty(list[key], 'valid_subject_ranks', { value: [] })    
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
