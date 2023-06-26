<template>
  <div id="edit_loan_task">
    <spinner
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px' }"
      v-if="settings.loading"
    />
    <h1>Edit loan</h1>
    <loan-recipient class="separate-bottom" />
    <template v-if="loan.id">
      <loan-items class="separate-top separate-bottom" />
      <edit-loan-items class="separate-top separate-bottom" />
      <LoanItemList class="separate-top" />
    </template>
  </div>
</template>

<script setup>
import loanRecipient from './components/loanRecipient.vue'
import loanItems from './components/loanItems.vue'
import editLoanItems from './components/editItemBar.vue'
import LoanItemList from './components/LoanItemList.vue'
import spinner from 'components/spinner.vue'

import ActionNames from './store/actions/actionNames'
import { GetterNames } from './store/getters/getters'
import { computed, onBeforeMount } from 'vue'
import { useStore } from 'vuex'

const store = useStore()

const settings = computed(() => store.getters[GetterNames.GetSettings])
const loan = computed(() => store.getters[GetterNames.GetLoan])

onBeforeMount(() => {
  const id = location.pathname.split('/')[4]
  const urlParams = new URLSearchParams(window.location.search)
  const loanId = urlParams.get('loan_id')
  const cloneFromId = urlParams.get('clone_from')

  if (/^\d+$/.test(loanId)) {
    store.dispatch(ActionNames.LoadLoan, loanId).catch(() => {
      window.location.href = '/tasks/loans/edit_loan/'
    })
  } else if (/^\d+$/.test(id)) {
    store.dispatch(ActionNames.LoadLoan, id).catch(() => {
      window.location.href = '/tasks/loans/edit_loan/'
    })
  } else if (/^\d+$/.test(cloneFromId)) {
    store.dispatch(ActionNames.CloneFrom, cloneFromId)
  }
})
</script>

<style lang="scss">
#edit_loan_task {
  flex-direction: column-reverse;
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;

  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
}
</style>
