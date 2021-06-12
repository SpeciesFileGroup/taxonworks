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
      v-if="modelValue">
      <span v-html="modelValue.object_tag"/>
      <span
        class="button circle-button btn-undo button-default"
        @click="$emit('input', undefined)"/>
    </span>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { TaxonName } from 'routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: { Autocomplete },

  props: {
    modelValue: {
      type: Object,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  mounted () {
    const params = URLParamsToJSON(location.href)
    if (params.ancestor_id) {
      this.getTaxon({ id: params.ancestor_id })
    }
  },

  methods: {
    getTaxon (event) {
      TaxonName.find(event.id).then(response => {
        this.$store.commit(MutationNames.SetTaxon, response.body)
        this.$emit('update:modelValue', response.body)
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
  :deep(.vue-autocomplete-list) {
    min-width: 800px;
  }
</style>
