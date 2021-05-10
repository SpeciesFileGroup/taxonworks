<template>
  <block-layout
    anchor="type"
    :warning="checkValidation"
    :spinner="!taxon.id"
    v-help.section.type.container>
    <h3 slot="header">Type</h3>
    <div
      slot="body">
      <div v-if="!taxonRelation">
        <div
          v-if="editType"
          class="horizontal-left-content">
          <span>
            <span v-html="GetRelationshipsCreated[0].object_status_tag"/>
            <a
              v-html="GetRelationshipsCreated[0].subject_object_tag"
              :href="`/tasks/nomenclature/browse?taxon_name_id=${GetRelationshipsCreated[0].subject_taxon_name_id}`"/>
          </span>
          <span
            class="button circle-button btn-undo button-default"
            @click="editType = undefined"/>
        </div>
        <quick-taxon-name
          slot="body"
          v-if="!showForThisGroup(['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], taxon) && (!(GetRelationshipsCreated.length) || editType)"
          @getItem="addTaxonType"
          :group="childOfParent[getRankGroup.toLowerCase()]"/>
        <template v-if="showForThisGroup(['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], taxon)">
          <ul class="no_bullets context-menu">
            <li>
              <a 
                :href="`/tasks/type_material/edit_type_material?taxon_name_id=${taxon.id}`"
                v-shortkey="[getMacKey(), 'm']"
                @shortkey="switchTypeMaterial()">Quick</a>
            </li>
            <li>
              <a
                :href="`/tasks/accessions/comprehensive?taxon_name_id=${taxon.id}`"
                v-shortkey="[getMacKey(), 'e']"
                @shortkey="switchComprehensive()">Comprehensive</a>
            </li>
          </ul>
          <ul class="table-entrys-list">
            <li
              class="flex-separate list-complete-item"
              v-for="typeSpecimen in typeMaterialList"
              :key="typeSpecimen.id">
              <a
                :href="`/tasks/type_material/edit_type_material?taxon_name_id=${taxon.id}&type_material_id=${typeSpecimen.id}`"
                v-html="typeSpecimen.object_tag"/>
              <a :href="`/tasks/accessions/comprehensive?collection_object_id=${typeSpecimen.collection_object_id}`">Open comprehensive</a>
            </li>
          </ul>
        </template>
      </div>
      <div v-else>
        <tree-display
          :tree-list="{ treeList }"
          :parent="parent"
          :object-lists="objectLists"
          :show-modal="showModal"
          valid-property="valid_object_ranks"
          @selected="addEntry"
          mutation-name-add="AddTaxonType"
          mutation-name-modal="SetModalType"
          name-module="Types"
          display-name="subject_status_tag"/>
        <div class="switch-radio">
          <input
            name="type-picker-options"
            id="type-picker-common"
            checked
            type="radio"
            class="normal-input button-active"
            @click="showAdvance = false">
          <label for="type-picker-common">Common</label>
          <input
            name="type-picker-options"
            id="type-picker-showall"
            type="radio"
            class="normal-input"
            @click="activeModal(true)">
          <label for="type-picker-showall">Show all</label>
        </div>
        <p class="inline">
          <span v-html="taxonRelation.hasOwnProperty('label_html') ? taxonRelation.label_html : taxonRelation.object_tag"/>
          <span
            type="button"
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="taxonRelation = undefined"/>
        </p>
        <div class="separate-top">
          <list-common
            :object-lists="objectLists.common"
            :filter="true"
            @addEntry="addEntry"
            display="subject_status_tag"
            :list-created="GetRelationshipsCreated"/>
        </div>
      </div>
      <list-entrys
        @update="loadTaxonRelationships"
        @addCitation="setType"
        :edit="true"
        :list="GetRelationshipsCreated"
        @delete="removeType"
        @edit="setEdit"
        :display="['subject_status_tag', { link: '/tasks/nomenclature/browse?taxon_name_id=', label: 'subject_object_tag', param: 'subject_taxon_name_id'}]"/>
    </div>
  </block-layout>
</template>
<script>

import showForThisGroup from '../helpers/showForThisGroup'
import BlockLayout from 'components/blockLayout'

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { TypeMaterial } from 'routes/endpoints'
import TreeDisplay from './treeDisplay.vue'
import ListEntrys from './listEntrys.vue'
import ListCommon from './commonList.vue'
import getRankGroup from '../helpers/getRankGroup'
import childOfParent from '../helpers/childOfParent'
import QuickTaxonName from './quickTaxonName'
import getMacKey from 'helpers/getMacKey.js'

export default {
  components: {
    ListEntrys,
    BlockLayout,
    TreeDisplay,
    ListCommon,
    QuickTaxonName
  },
  computed: {
    treeList () {
      return this.$store.getters[GetterNames.GetRelationshipList]
    },
    getRankGroup () {
      return getRankGroup(this.$store.getters[GetterNames.GetTaxon].rank_string)
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    GetRelationshipsCreated () {
      return this.$store.getters[GetterNames.GetTaxonRelationshipList].filter((item) => item.type.split('::')[1] === 'Typification')
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].taxonRelationshipList.list
    },
    checkValidation () {
      return !!this.softValidation.filter(item => this.GetRelationshipsCreated.find(created => created.id === item.instance.id)).length
    },
    taxonRelation: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonType]
      },
      set (value) {
        this.$store.commit(MutationNames.SetTaxonType, value)
      }
    },
    nomenclaturalCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
    },
    showModal () {
      return this.$store.getters[GetterNames.ActiveModalType]
    }
  },
  data: function () {
    return {
      objectLists: this.makeLists(),
      showAdvance: false,
      editType: undefined,
      childOfParent: childOfParent,
      typeMaterialList: []
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
    taxon: {
      handler (newVal, oldVal) {
        if (newVal.id && (!oldVal || newVal.id !== oldVal.id)) {
          TypeMaterial.where({ protonym_id: newVal.id }).then(response => {
            this.typeMaterialList = response.body
          })
        }
      },
      immediate: true,
      deep: true
    }
  },
  mounted () {
    TW.workbench.keyboard.createLegend((getMacKey() + '+' + 'm'), 'Go to new type material', 'New taxon name')
    TW.workbench.keyboard.createLegend((getMacKey() + '+' + 'c'), 'Go to comprehensive specimen digitization', 'New taxon name')
  },
  methods: {
    setEdit(relationship) {
      this.editType = relationship
      this.addTaxonType({
        id: relationship.subject_taxon_name_id,
        label_html: relationship.object_tag
      })
    },
    loadTaxonRelationships: function () {
      this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
    },
    setType (item) {
      this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item)
    },
    removeType: function (item) {
      let taxonName = Object.assign({}, this.$store.getters[GetterNames.GetTaxon])

      taxonName['type_taxon_name_relationship'] = undefined
      this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item)
      this.$store.commit(MutationNames.SetTaxon, taxonName)
    },
    refresh: function () {
      this.objectLists.tree = this.filterList(this.addType(Object.assign({}, this.treeList.typification.all)), this.getRankGroup)
      this.objectLists.common = this.filterList(this.addType(Object.assign({}, this.treeList.typification.common)), this.getRankGroup)
    },
    activeModal: function (value) {
      this.$store.commit(MutationNames.SetModalType, value)
    },
    makeLists: function () {
      return {
        tree: undefined,
        common: undefined
      }
    },
    addTaxonType: function (taxon) {
      this.taxonRelation = taxon
      if (this.getRankGroup == 'Family') { this.addEntry(this.objectLists.tree[Object.keys(this.objectLists.tree)[0]]) }
    },
    addEntry: function (item) {
      if(this.editType) {
        item.id = this.editType.id
        this.$store.dispatch(ActionNames.UpdateTaxonType, item).then(() => {
          this.$store.commit(MutationNames.UpdateLastChange)
          this.editType = undefined
        })
      }
      else {
        this.$store.dispatch(ActionNames.AddTaxonType, item).then(() => {
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      }
    },
    filterList: function (list, filter) {
      let tmp = {}

      for (var key in list) {
        if (key.split('::')[2] == filter) { tmp[key] = list[key] }
      }
      return tmp
    },
    addType (list) {
      for (var key in list) {
        Object.defineProperty(list[key], 'type', { value: key })
      }
      return list
    },
    switchTypeMaterial () {
      window.open(`/tasks/type_material/edit_type_material?taxon_name_id=${this.taxon.id}`, '_self')
    },
    switchComprehensive () {
      window.open(`/tasks/accessions/comprehensive?taxon_name_id=${this.taxon.id}`, '_self')
    },
    showForThisGroup: showForThisGroup,
    getMacKey: getMacKey
  }
}
</script>
