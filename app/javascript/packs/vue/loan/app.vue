<template>
  <div id="edit_loan_task">
    <spinner :full-screen="true" legend="Loading..." :logo-size="{ width: '100px', height: '100px'}" v-if="loading"></spinner>
    <h1>Edit loan</h1>
    <loan-recipient class="separate-bottom"></loan-recipient>
    <loan-items class="separate-top"></loan-items>
  </div>
</template>

<script>
  import loanRecipient from './components/loanRecipient.vue';
  import loanItems from './components/loanItems.vue';
  import spinner from '../components/spinner.vue';

  import ActionNames from './store/actions/actionNames';

  export default {
    components: {
      loanRecipient,
      loanItems,
      spinner
    },
    data: function() {
      return {
        loading: true,
      }
    },
    mounted: function() {
      var that = this;
      let loanId = location.pathname.split('/')[4];
      if(/^\d+$/.test(loanId)) {
        that.$store.dispatch(ActionNames.LoadLoan, loanId).then( function() {
          that.loading = false;
        });
      }
      else {
        that.loading = false;
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

    input[type="text"], textarea {
      width: 300px;
    }
    hr {
        height: 1px;
        color: #f5f5f5;
        background: #f5f5f5;
        font-size: 0;
        margin: 15px;
        border: 0;
    }
    .loan-box {

      transition: all 1s;

      label {
        display: block;
      }

      height: 100%;
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
      .header {
        border-left:4px solid green;
        h3 {
        font-weight: 300;
      }
      padding: 1em;
      padding-left: 1.5em;
      border-bottom: 1px solid #f5f5f5;
      }
      .body {
        padding: 2em;
        padding-top: 1em;
        padding-bottom: 1em;
      }
      .vue-autocomplete-input {
        width: 300px;
      }
      .taxonName-input,#error_explanation {
        width: 300px;
      }
    }
  }

</style>