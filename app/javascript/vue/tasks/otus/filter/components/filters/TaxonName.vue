<template>
  <div>
    <h2>Taxon names</h2>
    <smart-selector
      model="taxon_names"
      @selected="addTaxonName"/>
    <display-list
      label="object_tag"
      :delete-warning="false"
      :list="selectedTaxonNames"
      @delete="removeItem"/>
  </div>
</template>

<script>

import SmartSelector from 'components/smartSelector'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { GetTaxonName } from '../../request/resources'
import DisplayList from 'components/displayList'

export default {
  components: {
    SmartSelector,
    DisplayList
  },
  props: {
    value: {
      type: Array,
      default: undefined
    }
  },
  computed: {
    taxonNameIds: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      selectedTaxonNames: []
    }
  },
  watch: {
    taxonNameIds: {
      handler (newVal) {
        if (!newVal.length) {
          this.selectedTaxonNames = []
        }
      }
    }
  },
  mounted () {
    const urlParams = URLParamsToJSON(location.href)
    if (Object.keys(urlParams).length && urlParams.taxon_names_ids) {
      urlParams.taxon_names_ids.forEach(id => {
        GetTaxonName(id).then(response => {
          this.addTaxonName(response.body)
        })
      })
    }
  },
  methods: {
    addTaxonName (value) {
      this.selectedTaxonNames.push(value)
      this.taxonNameIds.push(value.id)
    },
    removeItem (item) {
      const index = this.selectedTaxonNames.findIndex(taxon => taxon.id === item.id)
      this.selectedTaxonNames.splice(index, 1)
      this.taxonNameIds.splice(index, 1)
    }
  }
}
</script>
