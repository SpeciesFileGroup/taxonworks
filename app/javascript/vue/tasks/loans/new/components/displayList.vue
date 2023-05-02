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
          @click="() => store.commit(MutationNames.CleanEditLoanItems)"
        >
          Unselect all
        </button>
        <button
          class="button normal-input separate-right button-default"
          v-else
          type="button"
          @click="() => store.commit(MutationNames.SetAllEditLoanItems)"
        >
          Select all
        </button>
      </div>
    </template>
    <template #body>
      <div
        v-if="pagination"
        class="horizontal-left-content flex-separate middle"
      >
        <VPagination
          :pagination="pagination"
          @next-page="
            store.dispatch(ActionNames.LoadLoanItems, { ...$event, per })
          "
        />
        <VPaginationCount
          v-model="per"
          :pagination="pagination"
        />
      </div>
      <table class="vue-table">
        <thead>
          <tr>
            <th />
            <th>Loan item</th>
            <th>Date returned</th>
            <th>Status</th>
            <th>Total</th>
            <th />
          </tr>
        </thead>
        <transition-group
          class="table-entrys-list"
          name="list-complete"
          tag="tbody"
        >
          <row-item
            v-for="item in list"
            :key="item.id"
            :item="item"
            @on-update="
              (item) => store.dispatch(ActionNames.UpdateLoanItem, item)
            "
            @on-delete="deleteItem"
          />
        </transition-group>
      </table>
    </template>
  </block-layout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import VPaginationCount from 'components/pagination/PaginationCount.vue'
import VPagination from 'components/pagination.vue'
import ActionNames from '../store/actions/actionNames'
import BlockLayout from 'components/layout/BlockLayout.vue'
import RowItem from './table/row'

const store = useStore()

const per = ref(50)
const list = computed(() => store.getters[GetterNames.GetLoanItems])
const pagination = computed(() => store.getters[GetterNames.GetPagination])
const editLoanItems = computed(
  () => store.getters[GetterNames.GetEditLoanItems]
)

function deleteItem(item) {
  if (
    window.confirm(
      "You're trying to delete a record. Are you sure want to proceed?"
    )
  ) {
    store.dispatch(ActionNames.DeleteLoanItem, item.id)
  }
}

watch(per, (newVal) =>
  store.dispatch(ActionNames.LoadLoanItems, { per: newVal })
)
</script>
