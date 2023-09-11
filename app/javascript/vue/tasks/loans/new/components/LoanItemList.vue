<template>
  <block-layout>
    <template #header>
      <h3>Loan items</h3>
    </template>
    <template #body>
      <div
        v-if="pagination"
        class="horizontal-left-content flex-separate middle"
      >
        <VPagination
          :pagination="pagination"
          @next-page="
            store.dispatch(ActionNames.LoadLoanItems, {
              ...$event,
              per,
              loanId: loan.id
            })
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
            <th>
              <input
                type="checkbox"
                v-model="selectLoanItems"
              />
            </th>
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
import VPaginationCount from '@/components/pagination/PaginationCount.vue'
import VPagination from '@/components/pagination.vue'
import ActionNames from '../store/actions/actionNames'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import RowItem from './table/row'

const store = useStore()

const per = ref(50)
const list = computed(() => store.getters[GetterNames.GetLoanItems])
const pagination = computed(() => store.getters[GetterNames.GetPagination])
const loan = computed(() => store.getters[GetterNames.GetLoan])
const editLoanItems = computed(
  () => store.getters[GetterNames.GetEditLoanItems]
)

const selectLoanItems = computed({
  get: () => editLoanItems.value.length === list.value.length,
  set: (value) => {
    store.commit(
      MutationNames.SetEditLoanItems,
      value ? list.value.map((item) => item.id) : []
    )
  }
})

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
  store.dispatch(ActionNames.LoadLoanItems, {
    loanId: loan.value.id,
    per: newVal
  })
)
</script>
