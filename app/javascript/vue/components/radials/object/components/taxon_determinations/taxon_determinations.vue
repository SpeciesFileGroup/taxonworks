<template>
  <div>
    <h3>Determinations</h3>
    <taxon-determination-form 
      create-form
      @on-add="addDetermination"
    />
    <display-list
      :list="list"
      @delete="removeTaxonDetermination"
      :radial-object="true"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script>

import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import DisplayList from 'components/displayList.vue'
import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../annotatorExtend.js'
import { TaxonDetermination } from 'routes/endpoints'

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: {
    TaxonDeterminationForm,
    DisplayList
  },

  methods: {
    addDetermination (taxon_determination) {
      if (
        this.list.find(determination =>
          determination.otu_id === taxon_determination.otu_id &&
          determination.year_made === taxon_determination.year_made)
      ) { return }

      Object.assign(taxon_determination, { biological_collection_object_id: this.metadata.object_id})

      TaxonDetermination.create({ taxon_determination }).then(response => {
        TW.workbench.alert.create('Taxon determination was successfully created.', 'notice')
        this.list.push(response.body)
      })
    },

    removeTaxonDetermination (determination) {
      this.removeItem(determination).then(_ => {
        TW.workbench.alert.create('Taxon determination was successfully destroyed.', 'notice')
      })
    }
  }
}
</script>