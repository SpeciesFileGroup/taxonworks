<template>
  <button
    type="button"
    v-shortkey="[getMacKey(), 's']"
    @shortkey="saveTaxon()"
    :disabled="!validateInfo || isSaving"
    @click="saveTaxon()">
    {{ taxon.id == undefined ? 'Create': 'Save' }}
  </button>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'

export default {
  computed: {
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    },
    validateInfo () {
      return (this.parent != undefined && 
        (this.taxon.name != undefined && 
        this.taxon.name.replace(' ','').length >= 2))
    },
    isSaving () {
      return this.$store.getters[GetterNames.GetSaving]
    }
  },
  methods: {
    saveTaxon: function () {
      if (this.validateInfo && !this.GetSaving) {
        if (this.taxon.id) {
          this.updateTaxonName()
        } else {
          this.createTaxonName()
        }
      }
    },
    getMacKey: function () {
      return (navigator.platform.indexOf('Mac') > -1 ? 'ctrl' : 'alt')
    },
    createTaxonName: function () {
      this.$store.dispatch(ActionNames.CreateTaxonName, this.taxon)
    },
    updateTaxonName: function () {
      this.$store.dispatch(ActionNames.UpdateTaxonName, this.taxon)
    }
  }
}
</script>
