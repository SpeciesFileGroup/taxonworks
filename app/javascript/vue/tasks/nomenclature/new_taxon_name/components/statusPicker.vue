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
        v-if="taxon.id"
        :tree-list="treeList"
        :object-lists="objectLists"
        :parent="parent"
        :show-modal="showModal"
        :filter="getStatusCreated"
        valid-property="valid_subject_ranks"
        @close="view = 'Common'"
        @selected="addEntry"
        mutation-name-add="AddTaxonStatus"
        mutation-name-modal="SetModalStatus"
        getter-list="GetTaxonStatusList"
        name-module="Status"
        display-name="name"/>
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
          :array-list="objectLists.allList"
          label="name"
          min="3"
          time="0"
          placeholder="Search"
          event-send="autocompleteStatusSelected"
          @getItem="addEntry"
          param="term"/>
        <list-common
          v-if="view != 'Advanced' && taxon.id"
          :filter="true"
          :object-lists="objectLists.commonList"
          display="name"
          @addEntry="addEntry"
          :list-created="getStatusCreated"/>
      </div>
      <ul
        v-if="!getStatusCreated.length && taxon.id === taxon.cached_valid_taxon_name_id"
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
    treeList () {
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
    showModal () {
      return this.$store.getters[GetterNames.ActiveModalStatus]
    },
    softValidation () {
      return this.$store.getters[GetterNames.GetSoftValidation].taxonStatusList.list
    },
    checkValidation () {
      return !!this.softValidation.filter(item => this.getStatusCreated.find(created => created.id === item.instance.id)).length
    },
    getStatusCreated () {
      return this.$store.getters[GetterNames.GetTaxonStatusList].filter((item) => item.type.split('::')[1] !== 'Latinized')
    }
  },

  data () {
    return {
      tabs: ['Common', 'Advanced', 'Show all'],
      view: 'Common',
      objectLists: this.makeLists(),
      expanded: true,
      showAdvance: false,
      editStatus: undefined
    }
  },

  watch: {
    taxonRank: {
      handler (newVal) {
        if (newVal) {
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
    makeLists () {
      return {
        tree: undefined,
        commonList: [],
        allList: []
      }
    },

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
      if(this.editStatus) {
        item.id = this.editStatus.id
        this.$store.dispatch(ActionNames.UpdateTaxonStatus, item).then(() => {
          this.editStatus = undefined
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      }
      else {
        this.$store.dispatch(ActionNames.AddTaxonStatus, item).then(() => {
          this.$store.commit(MutationNames.UpdateLastChange)
        })
      }
    },

    activeModal (value) {
      this.$store.commit(MutationNames.SetModalStatus, value)
    },

    refresh () {
      const copyList = JSON.parse(JSON.stringify(this.treeList[this.nomenclaturalCode]))

      this.objectLists = Object.assign({}, this.makeLists())
      this.objectLists.tree = Object.assign({}, copyList.tree)

      this.getStatusListForThisRank(copyList.all, this.taxon.rank_string).then(resolve => {
        this.objectLists.allList = resolve
        this.getTreeListForThisRank(this.objectLists.tree, copyList.all, resolve)
      })
      this.getStatusListForThisRank(copyList.common, this.parent.rank_string).then(resolve => {
        this.objectLists.commonList = resolve
      })
    },

    getStatusListForThisRank (list, findStatus) {
      return new Promise(function (resolve, reject) {
        const newList = []
        for (var key in list) {
          const t = list[key].applicable_ranks
          t.find(function (item) {
            if (item == findStatus) {
              newList.push(list[key])
              return true
            }
          })
        }
        resolve(newList)
      })
    },

    getTreeListForThisRank (list, ranksList, filteredList) {
      for (var key in list) {
        Object.defineProperty(list[key], 'name', { writable: true, value: ranksList[key].name })
        Object.defineProperty(list[key], 'type', { writable: true, value: ranksList[key].type })

        if (filteredList.find((item) => item.type === key)) {
          Object.defineProperty(list[key], 'disabled', { writable: true, value: false, configurable: true })
        } else {
          Object.defineProperty(list[key], 'disabled', { writable: true, value: true, configurable: true })
        }
        this.getTreeListForThisRank(list[key], ranksList, filteredList)
      }
    }
  }
}
</script>
