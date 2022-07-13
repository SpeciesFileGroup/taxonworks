<template>
  <block-layout
    anchor="type"
    :warning="checkValidation"
    :spinner="!taxon.id"
    v-help.section.type.container
  >
    <template #header>
      <h3>Type</h3>
    </template>
    <template #body>
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
          v-if="!showForThisGroup(['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], taxon) && (!(GetRelationshipsCreated.length) || editType)"
          @get-item="addTaxonType"
          :group="childOfParent[getRankGroup.toLowerCase()]"/>
        <template v-if="showForThisGroup(['SpeciesGroup', 'SpeciesAndInfraspeciesGroup'], taxon)">
          <ul class="no_bullets context-menu">
            <li>
              <a
                :href="`/tasks/type_material/edit_type_material?taxon_name_id=${taxon.id}`"
                v-hotkey="shortcuts">Quick</a>
            </li>
            <li>
              <a :href="`/tasks/accessions/comprehensive?taxon_name_id=${taxon.id}`">Comprehensive</a>
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
        <switch-component
          :options="Object.values(TAB)"
          v-model="view"
        />
        <tree-display
          v-if="view === TAB.showAll"
          :parent="parent"
          :list="objectLists.tree"
          :show-modal="showModal"
          valid-property="valid_object_ranks"
          :taxon-rank="taxon.rank_string"
          name-module="Types"
          display-name="subject_status_tag"
          @selected="addEntry"
          @close="view = TAB.common"
        />

        <p class="inline">
          <span v-html="taxonRelation.hasOwnProperty('label_html') ? taxonRelation.label_html : taxonRelation.object_tag"/>
          <span
            type="button"
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="taxonRelation = undefined"/>
        </p>

        <list-common
          v-if="view === TAB.common"
          class="separate-top"
          :object-lists="objectLists.common"
          :filter="true"
          @add-entry="addEntry"
          display="subject_status_tag"
          :list-created="GetRelationshipsCreated"/>
      </div>
      <list-entrys
        :list="GetRelationshipsCreated"
        :display="['subject_status_tag', { link: '/tasks/nomenclature/browse?taxon_name_id=', label: 'subject_object_tag', param: 'subject_taxon_name_id'}]"
        edit
        @delete="removeType"
        @edit="setEdit"
        @update="loadTaxonRelationships"
        @add-citation="setType"
      />
    </template>
  </block-layout>
</template>
<script>

import showForThisGroup from '../helpers/showForThisGroup'
import BlockLayout from 'components/layout/BlockLayout'

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
import platformKey from 'helpers/getPlatformKey.js'
import SwitchComponent from 'components/switch.vue'

export default {
  components: {
    ListEntrys,
    BlockLayout,
    TreeDisplay,
    ListCommon,
    QuickTaxonName,
    SwitchComponent
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
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+m`] = this.switchTypeMaterial
      keys[`${platformKey()}+e`] = this.switchComprehensive

      return keys
    },

    TAB: () => ({
      common: 'Common',
      showAll: 'Show all'
    })
  },

  data () {
    return {
      objectLists: this.makeLists(),
      showAdvance: false,
      editType: undefined,
      childOfParent,
      typeMaterialList: [],
      view: 'Common'
    }
  },

  watch: {
    parent: {
      handler (newVal) {
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
    TW.workbench.keyboard.createLegend((platformKey() + '+' + 'm'), 'Go to new type material', 'New taxon name')
    TW.workbench.keyboard.createLegend((platformKey() + '+' + 'c'), 'Go to comprehensive specimen digitization', 'New taxon name')
  },
  methods: {
    setEdit (relationship) {
      this.editType = relationship
      this.addTaxonType({
        id: relationship.subject_taxon_name_id,
        label_html: relationship.object_tag
      })
    },

    loadTaxonRelationships () {
      this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
    },

    setType (item) {
      this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item)
    },

    removeType (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item)
      this.$store.commit(MutationNames.SetTaxon, {
        ...this.taxon,
        type_taxon_name_relationship: undefined
      })
    },

    refresh () {
      this.objectLists.tree = this.filterList(this.addType(Object.assign({}, this.treeList.typification.all)), this.getRankGroup)
      this.objectLists.common = this.filterList(this.addType(Object.assign({}, this.treeList.typification.common)), this.getRankGroup)
    },

    activeModal (value) {
      this.$store.commit(MutationNames.SetModalType, value)
    },

    makeLists () {
      return {
        tree: undefined,
        common: undefined
      }
    },

    addTaxonType (taxon) {
      this.taxonRelation = taxon
      if (this.getRankGroup == 'Family') { 
        this.addEntry(this.objectLists.tree[Object.keys(this.objectLists.tree)[0]])
      }
    },

    addEntry (item) {
      const saveRequest = this.editType
        ? this.$store.dispatch(ActionNames.UpdateTaxonType, { ...item, id: this.editType.id })
        : this.$store.dispatch(ActionNames.AddTaxonType, item)

      saveRequest.then(_ => {
        this.$store.commit(MutationNames.UpdateLastChange)
        this.editType = undefined
      })
    },

    filterList (list, filter) {
      const tmp = {}

      for (const key in list) {
        if (key.split('::')[2] === filter) {
          tmp[key] = list[key]
        }
      }
      return tmp
    },

    addType (list) {
      for (const key in list) {
        list[key].type = key
      }
      return list
    },

    switchTypeMaterial () {
      window.open(`/tasks/type_material/edit_type_material?taxon_name_id=${this.taxon.id}`, '_self')
    },

    switchComprehensive () {
      window.open(`/tasks/accessions/comprehensive?taxon_name_id=${this.taxon.id}`, '_self')
    },

    showForThisGroup
  }
}
</script>
