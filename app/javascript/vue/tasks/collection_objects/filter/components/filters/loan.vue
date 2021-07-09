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
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  props: {
    modelValue: {
      type: Object,
      required: true,
    }
  },

  emits: ['update:modelValue'],

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
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    this.loans.on_loan = urlParams.on_loan
    this.loans.loaned = urlParams.loaned
    this.loans.never_loaned = urlParams.never_loaned
  }
}
</script>
