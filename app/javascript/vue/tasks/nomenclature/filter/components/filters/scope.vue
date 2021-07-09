<template>
  <div>
    <h3>Classification scope</h3>
    <label>Taxon name</label>
    <autocomplete
      url="/taxon_names/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search for a taxon name"
      :clear-after="true"
      :add-params="autocompleteParams"
      @getItem="setTaxon($event.id)"
    />
    <p
      v-if="selectedTaxon"
      class="field middle">
      <span
        class="margin-small-right"
        v-html="selectedTaxon.object_tag"/>
      <span
        class="separate-left button button-circle btn-undo button-default"
        @click="removeTaxon"/>
    </p>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'

export default {
  components: {
    Autocomplete
  },
  props: {
    modelValue: {
      default: undefined
    },
    autocompleteParams: {
      type: Object,
      default: () => ({})
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      selectedTaxon: undefined
    }
  },
  watch: {
    modelValue (newVal) {
      if (newVal && this.selectedTaxon && newVal[0] != this.selectedTaxon.id) {
        this.selectedTaxon = undefined
      }
    }
  },
  mounted () {
    const params = URLParamsToJSON(location.href)
    if (params.taxon_name_id) {
      this.setTaxon(params.taxon_name_id[0])
    }
  },
  methods: {
    setTaxon (id) {
      TaxonName.find(id).then(response => {
        this.selectedTaxon = response.body
        this.$emit('update:modelValue', [response.body.id])
      })
    },
    removeTaxon () {
      this.selectedTaxon = undefined
      this.$emit('update:modelValue', [])
    }
  }
}
</script>
<style scoped>
:deep(.vue-autocomplete-input) {
  width: 100%
}
</style>
