<template>
  <button
    type="button"
    v-hotkey="shortcuts"
    :disabled="!validateInfo || isSaving"
    @click="saveTaxon">
    {{ taxon.id ? 'Save': 'Create' }}
  </button>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import platformKey from 'helpers/getPlatformKey'

export default {
  computed: {
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },

    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },

    validateInfo () {
      return (this.parent &&
        (this.taxon.name &&
        this.taxon.name.replace(' ', '').length >= 2))
    },

    isSaving () {
      return this.$store.getters[GetterNames.GetSaving]
    },

    shortcuts () {
      const keys = {}

      keys[`${platformKey()}+s`] = this.saveTaxon

      return keys
    }
  },
  methods: {
    saveTaxon () {
      if (this.validateInfo && !this.GetSaving) {
        if (this.taxon.id) {
          this.updateTaxonName()
        } else {
          this.createTaxonName()
        }
      }
    },

    createTaxonName () {
      this.$store.dispatch(ActionNames.CreateTaxonName, this.taxon)
    },

    updateTaxonName () {
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
    }
  }
}
</script>
