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

import Autocomplete from 'components/autocomplete'
import { GetTaxonName } from '../../request/resources'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: {
    Autocomplete
  },
  props: {
    value: {
      default: undefined
    }
  },
  data () {
    return {
      selectedTaxon: undefined
    }
  },
  watch: {
    value (newVal) {
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
      GetTaxonName(id).then(response => {
        this.selectedTaxon = response.body
        this.$emit('input', [response.body.id])
      })
    },
    removeTaxon () {
      this.selectedTaxon = undefined
      this.$emit('input', [])
    }
  }
}
</script>
<style scoped>
>>> .vue-autocomplete-input { 
  width: 100%
}
</style>
