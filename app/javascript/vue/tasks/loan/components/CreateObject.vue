<template>
  <div>
    <p>Select loan item type</p>
    <div class="field">
      <label
        v-for="(item, key) in loanItemTypes"
        :key="key"
        class="label-flex">
        <input
          type="radio"
          v-model="typeSelected"
          :value="key"
        >
        {{ item.label }}
      </label>
    </div>
    <div class="field">
      <autocomplete
        v-if="!objectSelected"
        min="2"
        placeholder="Select loan item"
        label="label_html"
        display="label"
        :disabled="!typeSelected"
        clear-after
        @getItem="setObjectSelected"
        :url="typeAutocomplete"
        param="term"/>
      <div
        v-else
        class="horizontal-left-content middle">
        <span v-html="objectSelected.label_html"/>
        <button
          type="button"
          class="button circle-button button-default btn-undo"/>
      </div>
    </div>
    <div v-if="isTypeOtu">
      <div class="field">
        <label>Total</label>
        <input
          v-model="total"
          class="normal-input"
          type="text">
      </div>
      <button
        class="normal-input button button-submit"
        type="button"
        @click="createItem()">Create
      </button>
    </div>
  </div>
</template>

<script>

import { LoanItem } from 'routes/endpoints'
import { MutationNames } from '../store/mutations/mutations'
import Autocomplete from 'components/ui/Autocomplete.vue'
import extend from '../const/extend.js'

export default {
  components: { Autocomplete },

  props: {
    loan: {
      type: Object,
      required: true
    }
  },

  data () {
    return {
      objectSelected: undefined,
      typeSelected: 'CollectionObject',
      total: 1,
      loanItemTypes: {
        CollectionObject: {
          label: 'Collection Object',
          autocomplete: '/collection_objects/autocomplete'
        },
        Container: {
          label: 'Container',
          autocomplete: '/containers/autocomplete'
        },
        Otu: {
          label: 'OTU',
          autocomplete: '/otus/autocomplete'
        }
      }
    }
  },

  computed: {
    typeAutocomplete () {
      return this.loanItemTypes[this.typeSelected].autocomplete
    },

    isTypeOtu () {
      return this.typeSelected === 'Otu'
    }
  },

  watch: {
    objectSelected (newVal) {
      if (newVal && !this.isTypeOtu) {
        this.createItem()
      }
    },

    typeSelected () {
      this.objectSelected = undefined
    }
  },

  methods: {
    setObjectSelected (item) {
      this.objectSelected = item
    },

    createItem () {
      const data = {
        loan_id: this.loan.id,
        loan_item_object_id: this.objectSelected.id,
        loan_item_object_type: this.typeSelected,
        total: this.isTypeOtu ? this.total : undefined
      }

      LoanItem.create({ loan_item: data, extend }).then(response => {
        this.$store.commit(MutationNames.AddLoanItem, response.body)
        TW.workbench.alert.create('Loan item was successfully created.', 'notice')
      }).finally(() => {
        this.setObjectSelected(undefined)
      })
    }
  }
}
</script>
