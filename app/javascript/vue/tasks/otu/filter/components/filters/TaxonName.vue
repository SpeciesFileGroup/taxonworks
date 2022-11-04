<template>
  <div>
    <h3>Taxon names</h3>
    <smart-selector
      model="taxon_names"
      @selected="addTaxonName"
    />
    <display-list
      label="object_tag"
      :delete-warning="false"
      :list="selectedTaxonNames"
      @delete="removeItem"
    />
  </div>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector'
import DisplayList from 'components/displayList'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import { TaxonName } from 'routes/endpoints'

export default {
  components: {
    SmartSelector,
    DisplayList
  },

  props: {
    modelValue: {
      type: Array,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  computed: {
    taxonNameIds: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
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
        TaxonName.find(id).then(response => {
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
