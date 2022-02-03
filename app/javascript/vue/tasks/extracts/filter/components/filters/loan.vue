<template>
  <div>
    <h3>Loans</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input 
            v-model="loans.on_loan"
            type="checkbox">
          Currently on loan
        </label>
      </li>
      <li>
        <label>
          <input 
            v-model="loans.loaned"
            type="checkbox">
          Loaned
        </label>
      </li>
      <li>
        <label>
          <input
            v-model="loans.never_loaned"
            type="checkbox">
          Never loaned
        </label>
      </li>
    </ul>
    <autocomplete
      class="margin-medium-top"
      url="/loans/autocomplete"
      param="term"
      clear-after
      placeholder="Search a loan..."
      label="label_html"
      @getItem="addLoan($event.id)"
    />
    <display-list
      :list="loanList"
      label="object_tag"
      :delete-warning="false"
      @deleteIndex="removeLoan"/>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'
import { Loan } from 'routes/endpoints'
import Autocomplete from 'components/ui/Autocomplete.vue'
import DisplayList from 'components/displayList.vue'

export default {
  components: {
    Autocomplete,
    DisplayList
  },

  props: {
    modelValue: {
      type: Object,
      required: true,
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      loanList: []
    }
  },

  computed: {
    loans: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  watch: {
    loanList: {
      handler (newVal) {
        this.loans.loan_id = newVal.map(item => item.id)
      },
      deep: true
    }
  },

  created () {
    const urlParams = URLParamsToJSON(location.href)
    const loanIds = urlParams.loan_id || []

    this.loans.on_loan = urlParams.on_loan
    this.loans.loaned = urlParams.loaned
    this.loans.never_loaned = urlParams.never_loaned
    loanIds.forEach(id => this.addLoan(id))
  },

  methods: {
    addLoan (id) {
      Loan.find(id).then(({ body }) => {
        this.loanList.push(body)
      })
    },

    removeLoan (index) {
      this.loanList.splice(index, 1)
    }
  }
}
</script>
