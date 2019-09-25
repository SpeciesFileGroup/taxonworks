<template>
  <div>
    <h2>Taxon name</h2>
    <div class="field">
      <autocomplete
        class="fill_width"
        url="/taxon_names/autocomplete"
        param="term"
        display="label"
        label="label_html"
        :clear-after="true"
        placeholder="Search a taxon name"
        :add-params="{
          'type[]': 'Protonym'
        }"
        @getItem="getTaxon"/>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetTaxonName } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'

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
        this.$store.commit(MutationNames.SetTaxon, response.body)
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
  /deep/ .vue-autocomplete-list {
    min-width: 800px;
  }
</style>
