<template>
  <div class="panel content">
    <h2>Loans</h2>
    <fieldset>
      <legend>Loan</legend>
      <smart-selector
        model="loans"
        klass="CollectionObject"
        @selected="setLoan"/>
      <div
        v-if="loan"
        class="horizontal-left-content">
        <span v-html="loanLabel"/>
        <span class="button btn-undo button-default"/>
      </div>
    </fieldset>
    <fieldset>
      <legend>Person</legend>
      <smart-selector
        model="people"
        target="Determiner"
        :autocomplete="false"
        @selected="addRole">
        <role-picker
          class="margin-medium-top"
          roleType="Determiner"
          v-model="loanItem.roles_attributes"/>
      </smart-selector>
    </fieldset>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import RolePicker from 'components/role_picker'

export default {
  components: {
    SmartSelector,
    RolePicker
  },
  computed: {
    loanLabel () {
      if(!this.loan) return
      return loan.hasOwnProperty('object_tag') ? loan.object_tag : loan.html_label
    }
  },
  data () {
    return {
      loan: undefined,
      loanItem: {
        roles_attributes: []
      }
    }
  },
  methods: {
    setLoan(loan) {
      this.loan = loan
    },
    createLoanItem(id) {
      return {
        loan_item_object_type: 'CollectionObject',
        loan_item_object_id: id,
      }
    },
    roleExist(id) {
      return (this.loanItem.roles_attributes.find((role) => {
        return !role.hasOwnProperty('_destroy') && role.hasOwnProperty('person_id') && role.person_id == id
      }) ? true : false)
    },
    addRole(role) {
      if(!this.roleExist(role.id)) {
        this.loanItem.roles_attributes.push(CreatePerson(role, 'Determiner'))
      }
    },
  }
}
</script>

<style>

</style>