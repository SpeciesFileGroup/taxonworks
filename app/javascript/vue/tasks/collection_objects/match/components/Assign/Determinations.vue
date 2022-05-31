<template>
  <div class="panel content">
    <h2>Taxon determination</h2>
    <taxon-determination-form
      create-form
      @on-add="addDetermination"
    />
    <list-component
      :list="taxon_determinations"
      @delete-index="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script>

import ListComponent from 'components/displayList'
import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import { TaxonDetermination } from 'routes/endpoints'

export default {
  components: {
    ListComponent,
    TaxonDeterminationForm
  },

  props: {
    ids: {
      type: Array,
      required: true
    }
  },

  computed: {
    validateCreation () {
      return this.ids.length && this.taxon_determinations.length
    }
  },

  data () {
    return {
      taxon_determinations: [],
      isSaving: false
    }
  },

  methods: {
    addDetermination (taxonDetermination) {
      if (this.taxon_determinations.find((determination) => determination.otu_id === taxonDetermination.otu_id)) { return }
      this.taxon_determinations.push(taxonDetermination)

      this.createTaxonDeterminations()
    },

    createTaxonDeterminations (position = 0) {
      const promises = []

      if (position < this.ids.length) {
        this.taxon_determinations.forEach(determination => {
          determination.biological_collection_object_id = this.ids[position]
          promises.push(TaxonDetermination.create({ taxon_determination: determination }))
        })
        position++
      }

      Promise.allSettled(promises).then(response => {
        if (position < this.ids.length) {
          this.createTaxonDeterminations(position)
        } else {
          this.isSaving = false
          if (this.taxon_determinations.length) {
            TW.workbench.alert.create('Taxon determinations was successfully created.', 'notice')
          }
        }
      })
    },

    removeTaxonDetermination (index) {
      this.taxon_determinations.splice(index, 1)
    }
  }
}
</script>
