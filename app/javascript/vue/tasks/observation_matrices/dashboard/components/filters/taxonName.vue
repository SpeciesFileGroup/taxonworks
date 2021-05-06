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
        :clear-after="true"
        placeholder="Search a taxon name"
        :add-params="{
          'type[]': 'Protonym'
        }"
        @getItem="getTaxon"/>
    </div>
    <span
      class="horizontal-left-content"
      v-if="value">
      <span v-html="value.object_tag"/>
      <span
        class="button circle-button btn-undo button-default"
        @click="$emit('input', undefined)"/>
    </span>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete'
import { GetTaxonName } from '../../request/resources'
import { MutationNames } from '../../store/mutations/mutations'

import { URLParamsToJSON } from 'helpers/url/parse.js'

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
  mounted () {
    const params = URLParamsToJSON(location.href)
    if (params.ancestor_id) {
      this.getTaxon({ id: params.ancestor_id })
    }
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
  ::v-deep .vue-autocomplete-list {
    min-width: 800px;
  }
</style>
