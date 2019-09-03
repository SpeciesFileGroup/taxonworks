<template>
  <div>
    <h3>Taxon name</h3>
    <div class="field">
      <autocomplete
        class="fill_width"
        url="/taxon_names/autocomplete"
        param="term"
        display="label"
        label="label_html"
        placeholder="Search a taxon name"
        @getItem="getTaxon"/>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetTaxonName } from '../../request/resources'

export default {
  props: {
    value: {
      type: Object,
      default: undefined
    }
  },
  components: {
    Autocomplete
  },
  methods: {
    getTaxon (event) {
      GetTaxonName(event.id).then(response => {
        this.taxonName = response.body
        this.$emit('input', response.body)
      })
    }
  }
}
</script>

<style lang="scss" scoped>
  .field {
    label {
      display: block;
    }
  }
  .field-year {
    width: 60px;
  }
</style>
