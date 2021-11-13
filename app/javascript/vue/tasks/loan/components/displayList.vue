<template>
  <block-layout>
    <template #header>
      <h3>Loan items</h3>
    </template>
    <template #options>
      <div class="horizontal-left-content">
        <button
          class="button normal-input separate-right button-default"
          v-if="editLoanItems.length"
          type="button"
          @click="unselectAll()">Unselect all
        </button>
        <button
          class="button normal-input separate-right button-default"
          v-else
          type="button"
          @click="selectAll()">Select all
        </button>
        <expand
          class="separate-left"
          v-model="displayBody"/>
      </div>
    </template>
    <template
      #body
      v-if="displayBody">
      <table class="vue-table">
        <thead>
          <tr>
            <th />
            <th>Loan item</th>
            <th>Date returned</th>
            <th>Collection object status</th>
            <th>Total</th>
            <th>Pin</th>
            <th>Radial</th>
            <th>Delete</th>
          </tr>
        </thead>
        <transition-group
          class="table-entrys-list"
          name="list-complete"
          tag="tbody">
          <row-item
            v-for="item in list"
            :key="item.id"
            :item="item"
            @onUpdate="updateItem"
            @onDelete="deleteItem"
          />
        </transition-group>
      </table>
    </template>
  </block-layout>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import ActionNames from '../store/actions/actionNames'

import BlockLayout from 'components/layout/BlockLayout.vue'
import Expand from './expand.vue'
import RowItem from './table/row'

export default {
  components: {
    BlockLayout,
    RowItem,
    Expand
  },

  computed: {
    list () {
      return this.$store.getters[GetterNames.GetLoanItems]
    },

    editLoanItems () {
      return this.$store.getters[GetterNames.GetEditLoanItems]
    }
  },

  data () {
    return {
      selectedItems: [],
      displayBody: true
    }
  },

  methods: {
    selectAll () {
      this.$store.commit(MutationNames.SetAllEditLoanItems)
    },

    unselectAll () {
      this.$store.commit(MutationNames.CleanEditLoanItems)
    },

    deleteItem (item) {
      if (window.confirm('You\'re trying to delete a record. Are you sure want to proceed?')) {
        this.$store.dispatch(ActionNames.DeleteLoanItem, item.id)
      }
    },

    updateItem (item) {
      this.$store.dispatch(ActionNames.UpdateLoanItem, item)
    },

    removeSelectedItem (item) {
      this.$store.commit(MutationNames.RemoveEditLoanItem, item)
    }
  }
}
</script>
