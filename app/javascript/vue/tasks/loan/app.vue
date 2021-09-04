<template>
  <div id="edit_loan_task">
    <spinner
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="settings.loading"/>
    <h1>Edit loan</h1>
    <loan-recipient class="separate-bottom"/>
    <loan-items class="separate-top separate-bottom"/>
    <edit-loan-items class="separate-top separate-bottom"/>
    <display-list class="separate-top"/>
  </div>
</template>

<script>
  import loanRecipient from './components/loanRecipient.vue'
  import loanItems from './components/loanItems.vue'
  import editLoanItems from './components/editItemBar.vue'
  import displayList from './components/displayList.vue'
  import spinner from 'components/spinner.vue'

  import ActionNames from './store/actions/actionNames'
  import { GetterNames } from './store/getters/getters'

  export default {
    components: {
      loanRecipient,
      loanItems,
      displayList,
      editLoanItems,
      spinner
    },
    computed: {
      settings() {
        return this.$store.getters[GetterNames.GetSettings]
      }
    },
    data: function () {
      return {
        loading: true
      }
    },
    mounted: function () {
      let that = this
      let id = location.pathname.split('/')[4]
      let urlParams = new URLSearchParams(window.location.search)
      let loanId = urlParams.get('loan_id')

      if (/^\d+$/.test(loanId)) {
        that.$store.dispatch(ActionNames.LoadLoan, loanId).then(response => {
        }, () => {
          window.location.href = '/tasks/loans/edit_loan/'
        })
      } else if (/^\d+$/.test(id)) {
        that.$store.dispatch(ActionNames.LoadLoan, id).then(response => {
        }, () => {
          window.location.href = '/tasks/loans/edit_loan/'
        })
      }
    }
  }

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
