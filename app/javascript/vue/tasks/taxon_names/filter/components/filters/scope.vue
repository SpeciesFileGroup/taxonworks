<template>
  <div>
    <h2>Scope</h2>
    <label>Return these names</label>
    <autocomplete 
      url="/taxon_names/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search for a taxon name"
      :clear-after="true"
      :add-params="{ no_leaves: true }"
      @getItem="setTaxon"
    />
    <p
      v-if="selectedTaxon"
      v-html="selectedTaxon.label_html"/>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'

export default {
  components: {
    Autocomplete
  },
  props: {
    value: {
      default: undefined
    }
  },
  data() {
    return {
      selectedTaxon: undefined
    }
  },
  watch: {
    value(newVal) {
      if(newVal && this.selectedTaxon && newVal[0] != this.selectedTaxon.id) {
        this.selectedTaxon = undefined
      }
    }
  },
  methods: {
    setTaxon(value) {
      this.selectedTaxon = value
      this.$emit('input', [value.id])
    }
  }
}
</script>
<style scoped>
>>> .vue-autocomplete-input { 
  width: 100%
}
</style>
