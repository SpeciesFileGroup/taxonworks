<template>
  <form class="panel basic-information">
    <a
      name="type"
      class="anchor"/>
    <div
      class="header flex-separate middle"
      :class="{ 'validation-warning' : softValidation.taxonRelationshipList.list.length }">
      <h3
      v-help.section.type.container
      >Type</h3>
      <expand
        @changed="expanded = !expanded"
        :expanded="expanded"/>
    </div>
    <div
      class="body"
      v-if="expanded">
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
        <hard-validation
          field="type"
          v-if="!showForThisGroup(['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], taxon) && (!(GetRelationshipsCreated.length) || editType)">
          <quick-taxon-name
            slot="body"
            @getItem="addTaxonType"
            :group="childOfParent[getRankGroup.toLowerCase()]"/>
        </hard-validation>
        <template v-if="showForThisGroup(['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], taxon)">
          <ul class="no_bullets context-menu">
            <li>
              <a :href="`/tasks/type_material/edit_type_material?taxon_name_id=${taxon.id}`">Quick</a>
            </li>
            <li>
              <a :href="`/tasks/accessions/comprehensive?taxon_name_id=${taxon.id}`">Comprehensive</a>
            </li>
          </ul>
          <hr>
          <ul class="no_bullets">
            <li
              v-for="typeSpecimen in typeMaterialList"
              :key="typeSpecimen.id">
              <a
                :href="`/tasks/type_material/edit_type_material?taxon_name_id=${taxon.id}&type_material_id=${typeSpecimen.id}`"
                v-html="typeSpecimen.object_tag"/>
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
          display-name="object_status_tag"/>
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
            display="object_status_tag"
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
        :display="['object_status_tag', { link: '/tasks/nomenclature/browse?taxon_name_id=', label: 'subject_object_tag', param: 'subject_taxon_name_id'}]"/>
    </div>
  </form>
</template>
<script>

import showForThisGroup from '../helpers/showForThisGroup'

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
import childOfParent from '../helpers/childOfParent'
import QuickTaxonName from './quickTaxonName'

import { GetTypeMaterial } from '../request/resources.js'

export default {
  components: {
    ListEntrys,
    Autocomplete,
    Expand,
    TreeDisplay,
    ListCommon,
    QuickTaxonName,
    HardValidation
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
      var type = []
      type = this.$store.getters[GetterNames.GetTaxonRelationshipList].filter(function (item) {
        return (item.type.split('::')[1] == 'Typification')
      })
      if (!type.length) {
        if (this.taxon.hasOwnProperty('type_taxon_name_relationship') && this.taxon['type_taxon_name_relationship']) {
          type.push(this.taxon.type_taxon_name_relationship)
          return type
        }
      }
      return type
    },
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation]
    },
    taxonRelation: {
      get () {
        return this.$store.getters[GetterNames.GetTaxonType]
      },
      set (value) {
        this.$store.commit(MutationNames.UpdateLastChange)
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
      expanded: true,
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
      handler(newVal) {
        if(newVal.id) {
          GetTypeMaterial(newVal.id).then(response => {
            this.typeMaterialList = response
          }) 
        }
      },
      immediate: true,
      deep: true
    }
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
          this.$store.commit(MutationNames.UpdateLastSave)
          this.editType = undefined
          this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
        })
      }
      else {
        this.$store.dispatch(ActionNames.AddTaxonType, item).then(() => {
          this.$store.commit(MutationNames.UpdateLastSave)
          this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
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
    showForThisGroup: showForThisGroup
  }
}
</script>
