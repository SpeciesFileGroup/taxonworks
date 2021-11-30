<template>
  <div class="panel content">
    <h2>Loans</h2>
    <fieldset>
      <legend>Loan</legend>
      <smart-selector
        model="loans"
        klass="CollectionObject"
        @selected="setLoan"/>
      <p
        v-if="loan"
        class="horizontal-left-content">
        <span v-html="loanLabel"/>
        <span
          class="button btn-undo circle-button button-default"
          @click="loan = undefined"/>
      </p>
    </fieldset>
    <div class="field label-above margin-medium-top">
      <label>Date returned</label>
      <input
        type="date"
        v-model="loanItem.date_returned">
    </div>
    <div class="field label-above">
      <label>Status</label>
      <select v-model="loanItem.disposition">
        <option
          v-for="item in status"
          :key="item"
          :value="item">
          {{ item }}
        </option>
      </select>
    </div>
    <div>
      <button
        type="button"
        class="button normal-input button-submit"
        :disabled="!validateFields"
        @click="CreateLoanItems">
        Create
      </button>
    </div>
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import { Loan } from 'routes/endpoints'

export default {
  components: { SmartSelector },

  props: {
    ids: {
      type: Array,
      required: true
    }
  },

  computed: {
    loanLabel () {
      if (!this.loan) return
      return this.loan?.object_tag || this.loan.html_label
    },
    validateFields () {
      return this.ids.length && this.loanItem.disposition
    }
  },

  data () {
    return {
      loan: undefined,
      loanItem: {
        disposition: undefined,
        date_returned: undefined
      },
      status: [
        'Destroyed',
        'Donated',
        'Lost',
        'Retained',
        'Returned'
      ]
    }
  },
  methods: {
    setLoan (loan) {
      this.loan = loan
    },

    CreateLoanItems () {
      const loan_items_attributes = this.ids.map(id => ({
        loan_item_object_id: id,
        loan_item_object_type: 'CollectionObject',
        disposition: this.loanItem.disposition,
        date_returned: this.loanItem.date_returned
      }))

      Loan.update(this.loan.id, { loan: { loan_items_attributes } }).then(response => {
        TW.workbench.alert.create('Loan items was successfully created.', 'notice')
      })
    }
  }
}
</script>
