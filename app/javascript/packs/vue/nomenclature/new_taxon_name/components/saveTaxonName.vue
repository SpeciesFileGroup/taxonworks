<template>
  <button
    type="button"
    v-shortkey="[getMacKey(), 's']"
    @shortkey="saveTaxon()"
    :disabled="!validateInfo()"
    @click="saveTaxon()">
    {{ taxon.id == undefined ? 'Create': 'Save' }}
  </button>
</template>

<script>

const GetterNames = require('../store/getters/getters').GetterNames
const ActionNames = require('../store/actions/actions').ActionNames

export default {
  computed: {
    parent () {
      return this.$store.getters[GetterNames.GetParent]
    },
    taxon () {
      return this.$store.getters[GetterNames.GetTaxon]
    }
  },
  methods: {
    saveTaxon: function () {
      if (this.validateInfo()) {
        if (this.taxon.id == undefined) {
          this.createTaxonName()
        } else {
          this.updateTaxonName()
        }
      }
    },
    validateInfo: function () {
      return (this.parent != undefined && (this.taxon.name != undefined && this.taxon.name != ''))
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
