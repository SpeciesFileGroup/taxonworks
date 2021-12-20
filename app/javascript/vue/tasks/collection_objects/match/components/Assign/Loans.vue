<template>
  <div class="panel content">
    <h2>Loans</h2>
    <fieldset>
      <legend>Loan</legend>
      <smart-selector
        v-model="loan"
        model="loans"
        klass="CollectionObject"
      />
      <smart-selector-item
        :item="loan"
        @unset="setLoan"
      />
    </fieldset>
    <div class="margin-medium-top">
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

import { Loan } from 'routes/endpoints'
import SmartSelector from 'components/ui/SmartSelector'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'

export default {
  components: {
    SmartSelector,
    SmartSelectorItem
  },

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
      return this.ids.length
    }
  },

  data () {
    return {
      loan: undefined
    }
  },
  methods: {
    setLoan (loan) {
      this.loan = loan
    },

    CreateLoanItems () {
      const loan_items_attributes = this.ids.map(id => ({
        loan_item_object_id: id,
        loan_item_object_type: 'CollectionObject'
      }))

      Loan.update(this.loan.id, { loan: { loan_items_attributes } }).then(_ => {
        TW.workbench.alert.create('Loan items was successfully created.', 'notice')
      })
    }
  }
}
</script>
