<template>
  <block-layout
    :warning="checkValidation"
    anchor="status">
    <h3 slot="header">
      Status
    </h3>
    <div
      slot="body">
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
import BlockLayout from './blockLayout'
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
      return this.softValidation?.find(item => this.GetRelationshipsCreated.find(created => created.global_id === item.global_id))
    },
    getStatusCreated () {
      return this.$store.getters[GetterNames.GetTaxonStatusList].filter(function (item) {
        return (item.type.split('::')[1] != 'Latinized')
      })
    }
  },
  data: function () {
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
    makeLists: function () {
      return {
        tree: undefined,
        commonList: [],
        allList: []
      }
    },
    loadTaxonStatus: function () {
      this.$store.dispatch(ActionNames.LoadTaxonStatus, this.taxon.id)
    },
    setCitation: function (item) {
      this.$store.dispatch(ActionNames.UpdateClassification, item)
    },
    removeStatus: function (item) {
      this.$store.dispatch(ActionNames.RemoveTaxonStatus, item)
    },
    addEntry: function (item) {
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
    activeModal: function (value) {
      this.$store.commit(MutationNames.SetModalStatus, value)
    },
    refresh: function () {
      let copyList = Object.assign({}, this.treeList[this.nomenclaturalCode])

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
        var
          newList = []
        for (var key in list) {
          var t = list[key].applicable_ranks
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
        Object.defineProperty(list[key], 'name', { value: ranksList[key].name })
        Object.defineProperty(list[key], 'type', { value: ranksList[key].type })

        if (filteredList.find(function (item) {
          if (item.type == key) {
            return true
          }
        })) {
          Object.defineProperty(list[key], 'disabled', { value: false, configurable: true })
        } else {
          Object.defineProperty(list[key], 'disabled', { value: true, configurable: true })
        }
        this.getTreeListForThisRank(list[key], ranksList, filteredList)
      }
    }
  }
}
</script>
