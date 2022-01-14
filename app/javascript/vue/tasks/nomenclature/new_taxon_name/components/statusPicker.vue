<template>
  <block-layout
    :warning="checkValidation"
    anchor="status"
    :spinner="!taxon.id">
    <template #header>
      <h3>Status</h3>
    </template>
    <template #body>
      <tree-display
        v-if="taxon.id && showModal"
        :tree-list="objectLists.tree"
        :object-lists="objectLists"
        :taxon-rank="taxon.rank_string"
        :filter="getStatusCreated"
        :created-list="getStatusCreated"
        title="Status"
        display-name="name"
        @close="view = 'Common'; showModal = false"
        @selected="addEntry"
      />
      <div v-if="editStatus">
        <p class="inline">
          <span class="separate-right">Editing status: </span>
          <span v-html="editStatus.object_tag"/>
          <span
            title="Undo"
            class="circle-button button-default btn-undo"
            @click="editStatus = undefined"/>
        </p>
      </div>
      <switch-component
        v-model="view"
        :options="tabs"/>
      <div class="separate-top">
        <autocomplete
          v-if="view == 'Advanced'"
          :array-list="objectLists.all"
          label="name"
          min="3"
          time="0"
          placeholder="Search"
          event-send="autocompleteStatusSelected"
          @getItem="addEntry"
          param="term"/>
        <list-common
          v-if="view != 'Advanced' && taxon.id"
          filter
          :object-lists="objectLists.common"
          display="name"
          @addEntry="addEntry"
          :list-created="getStatusCreated"/>
      </div>
      <ul
        v-if="!getStatusCreated.length && taxon.cached_is_valid"
        class="table-entrys-list">
        <li class="list-complete-item middle">
          <p>Valid as default</p>
        </li>
      </ul>
      <list-entrys
        @update="loadTaxonStatus"
        @addCitation="setCitation"
        @delete="removeStatus"
        @edit="editStatus = $event"
        :edit="true"
        :list="getStatusCreated"
        :display="['object_tag']"/>
    </template>
  </block-layout>
</template>

<script>
import { ActionNames } from '../store/actions/actions'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { createStatusLists } from '../helpers/createStatusLists'
import TreeDisplay from './treeDisplay.vue'
import ListEntrys from './listEntrys.vue'
import ListCommon from './commonList.vue'
import Autocomplete from 'components/ui/Autocomplete.vue'
import BlockLayout from 'components/layout/BlockLayout'
import SwitchComponent from 'components/switch'

export default {
  components: {
    ListEntrys,
    TreeDisplay,
    ListCommon,
    Autocomplete,
    SwitchComponent,
    BlockLayout
  },

  computed: {
    statusList () {
      return this.$store.getters[GetterNames.GetStatusList]
    },

    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    taxonRank () {
      return this.$store.getters[GetterNames.GetRankClass]
    },

    nomenclaturalCode () {
      return this.$store.getters[GetterNames.GetNomenclaturalCode]
    },

    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].taxonStatusList.list
    },

    checkValidation () {
      return !!this.softValidation.filter(item => this.getStatusCreated.find(created => created.id === item.instance.id)).length
    },

    getStatusCreated () {
      return this.$store.getters[GetterNames.GetTaxonStatusList].filter(item => item.type.split('::')[1] !== 'Latinized')
    }
  },

  data () {
    return {
      tabs: ['Common', 'Advanced', 'Show all'],
      view: 'Common',
      objectLists: {
        tree: [],
        common: [],
        all: []
      },
      expanded: true,
      showAdvance: false,
      editStatus: undefined,
      showModal: false
    }
  },

  watch: {
    taxonRank: {
      handler (newVal) {
        if (newVal) {
          this.refreshLists()
        }
      }
    },

    parent: {
      handler (newVal) {
        if (newVal) {
          this.refreshLists()
        }
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
    loadTaxonStatus () {
      this.$store.dispatch(ActionNames.LoadTaxonStatus, this.taxon.id)
    },

    setCitation (item) {
      this.$store.dispatch(ActionNames.UpdateClassification, item)
    },

    removeStatus (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonStatus, item)
    },

    addEntry (item) {
      if (this.editStatus) {
        item.id = this.editStatus.id
        this.$store.dispatch(ActionNames.UpdateTaxonStatus, item).then(() => {
          this.editStatus = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      } else {
        this.$store.dispatch(ActionNames.AddTaxonStatus, item).then(() => {
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      }
    },

    activeModal (value) {
      this.showModal = value
    },

    refreshLists () {
      const list = this.statusList[this.nomenclaturalCode] || {}

      this.objectLists = createStatusLists(list, this.taxon.rank_string, this.parent.rank_string)
    }
  }
}
</script>
