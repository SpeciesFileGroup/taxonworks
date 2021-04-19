<template>
  <div class="panel loan-box">
    <spinner
      :show-spinner="false"
      :resize="false"
      :show-legend="false"
      v-if="!loan.id"/>
    <div class="header flex-separate middle">
      <h3>Loan items</h3>
      <div class="horizontal-left-content">
        <template>
          <button
            class="button normal-input separate-right"
            v-if="editLoanItems.length"
            type="button"
            @click="unselectAll()">Unselect all
          </button>
          <button
            class="button normal-input separate-right"
            v-else
            type="button"
            @click="selectAll()">Select all
          </button>
        </template>
        <expand
          class="separate-left"
          v-model="displayBody"/>
      </div>
    </div>
    <div
      class="body"
      v-if="displayBody">
      <table class="vue-table">
        <thead>
          <tr>
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
    </div>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import ActionNames from '../store/actions/actionNames'

import Spinner from 'components/spinner.vue'
import Expand from './expand.vue'
import RowItem from './table/row'

export default {
  components: {
    RowItem,
    Spinner,
    Expand
  },

  computed: {
    list () {
      return this.$store.getters[GetterNames.GetLoanItems]
    },
    loan () {
      return this.$store.getters[GetterNames.GetLoan]
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
<style lang="scss" scoped>
  .vue-table-container {
    overflow-y: scroll;
    padding: 0px;
    position: relative;
  }

  .vue-table {
    width: 100%;
    .vue-table-options {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
    }
    tr {
      border: 1px solid #F5F5F5;
      cursor: default;
    }

  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter, .list-complete-leave-to {
    opacity: 0;
    font-size: 0px;
    border: none;
    transform: scale(0.0);
  }

  .list-complete-leave-active {
    width: 100%;
    position: absolute;
  }
</style>
