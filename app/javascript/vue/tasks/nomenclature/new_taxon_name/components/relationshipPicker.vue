<template>
  <block-layout
    anchor="relationship"
    :warning="checkValidation"
    :spinner="!taxon.id"
    v-help.section.relationship.container>
    <template #header>
      <h3>Relationship</h3>
    </template>
    <template #body>
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
        <div class="horizontal-left-content">
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
            v-if="showModal"
            :taxon-rank="taxon.rank_string"
            :list="objectLists.tree"
            valid-property="valid_subject_ranks"
            :list-created="GetRelationshipsCreated"
            title="Relationship"
            display-name="subject_status_tag"
            @close="view = 'Common'; showModal = false"
            @selected="addEntry"
          />

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
    </template>
  </block-layout>
</template>
<script>

import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { TAXON_RELATIONSHIP_CURRENT_COMBINATION } from 'constants/index.js'
import TreeDisplay from './treeDisplay.vue'
import ListEntrys from './listEntrys.vue'
import ListCommon from './commonList.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import getRankGroup from '../helpers/getRankGroup'
import SwitchComponent from 'components/switch'
import BlockLayout from 'components/layout/BlockLayout'

const FILTER_RELATIONSHIPS = [
  TAXON_RELATIONSHIP_CURRENT_COMBINATION,
  'OriginalCombination',
  'Typification',
  'UncertainPlacement',
  'SourceClassifiedAs'
]

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
    taxonLabel () {
      return this.taxonRelation.label_html || this.taxonRelation.object_tag
    },

    treeList () {
      return this.$store.getters[GetterNames.GetRelationshipList]
    },

    getRankGroup () {
      return getRankGroup(this.$store.getters[GetterNames.GetTaxon].rank_string)
    },

    GetRelationshipsCreated () {
      return this.$store.getters[GetterNames.GetTaxonRelationshipList].filter(item => !FILTER_RELATIONSHIPS.some(filterType => item.type.includes(filterType)))
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
      return !!this.softValidation.filter(item => this.GetRelationshipsCreated.find(created => created.id === item.instance.id)).length
    },

    nomenclaturalCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
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
      },
      showModal: false
    }
  },
  watch: {
    taxon: {
      handler (newVal, oldVal) {
        if(newVal.id && newVal.id !== oldVal.id) {
          this.refresh()
        }
      }
    },
    parent: {
      handler (newVal) {
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
    setInsertaeSedis () {
      this.isInsertaeSedis = true
      this.taxonRelation = this.parent
    },

    loadTaxonRelationships () {
      this.$store.dispatch(ActionNames.LoadTaxonRelationships, this.taxon.id)
    },

    removeRelationship (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonRelationship, item).then(() => {
        this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
      })
    },

    setRelationship (item) {
      this.$store.dispatch(ActionNames.UpdateTaxonRelationship, item)
    },

    refresh () {
      const copyList = JSON.parse(JSON.stringify(this.treeList[this.nomenclaturalCode] || {}))

      this.objectLists.tree = copyList.tree || {}
      this.objectLists.commonList = copyList.common || {}
      this.objectLists.allList = copyList.all || {}
      this.addType(this.objectLists.allList)
      this.objectLists.allList = Object.keys(this.objectLists.allList).map(key => this.objectLists.allList[key])
      this.getTreeList(this.objectLists.tree, copyList.all)
      this.addType(this.objectLists.commonList)
    },

    activeModal (value) {
      this.showModal = value
    },

    makeLists () {
      return {
        tree: undefined,
        commonList: [],
        allList: []
      }
    },

    addEntry (item) {
      if (this.editMode) {
        const relationship = {
          id: this.editMode.id,
          subject_taxon_name_id: this.taxon.id,
          object_taxon_name_id: this.taxonRelation?.object_taxon_name_id || this.taxonRelation.id,
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
          object_taxon_name_id: this.taxonRelation.id,
          subject_taxon_name_id: this.taxon.id
        }).then(() => {
          this.taxonRelation = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      }
      this.isInsertaeSedis = false
    },

    closeEdit () {
      this.editMode = undefined
      this.taxonRelation = undefined
    },

    editRelationship (value) {
      this.taxonRelation = value
      this.editMode = this.taxonRelation
    },

    getTreeList (list, ranksList) {
      for (const key in list) {
        if (key in ranksList) {
          Object.defineProperty(list[key], 'type', { writable: true, value: key })
          Object.defineProperty(list[key], 'object_status_tag', { writable: true, value: ranksList[key].object_status_tag })
          Object.defineProperty(list[key], 'subject_status_tag', { writable: true, value: ranksList[key].subject_status_tag })
          Object.defineProperty(list[key], 'valid_subject_ranks', { writable: true, value: ranksList[key].valid_subject_ranks })
        }
        else {
          const label = key.split('::')

          Object.defineProperty(list[key], 'type', { writable: true, value: key })
          Object.defineProperty(list[key], 'object_status_tag', { writable: true, value: label[label.length - 1].replace(/\.?([A-Z])/g, (x, y) => ' ' + y.toLowerCase()).replace(/^_/, '').toLowerCase().trim() })
          Object.defineProperty(list[key], 'subject_status_tag', { writable: true, value: label[label.length - 1].replace(/\.?([A-Z])/g, (x, y) => ' ' + y.toLowerCase()).replace(/^_/, '').toLowerCase().trim() })
          Object.defineProperty(list[key], 'valid_subject_ranks', { writable: true, value: [] })
        }
        this.getTreeList(list[key], ranksList)
      }
    },
    addType (list) {
      for (const key in list) {
        Object.defineProperty(list[key], 'type', { writable: true, value: key })
      }
    }
  }
}
</script>
