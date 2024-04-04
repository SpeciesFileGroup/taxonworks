<template>
  <div>
    <h3>Determinations</h3>
    <TaxonDeterminationForm
      create-form
      @on-add="addDetermination"
    />
    <DisplayList
      :list="list"
      @delete="removeTaxonDetermination"
      :radial-object="true"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script>
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import DisplayList from '@/components/displayList.vue'
import CRUD from '../../request/crud.js'
import AnnotatorExtend from '../annotatorExtend.js'
import { TaxonDetermination } from '@/routes/endpoints'

export default {
  mixins: [CRUD, AnnotatorExtend],

  components: {
    TaxonDeterminationForm,
    DisplayList
  },

  methods: {
    addDetermination(taxonDetermination) {
      if (
        this.list.find(
          (determination) =>
            determination.otu_id === taxonDetermination.otu_id &&
            determination.year_made === taxonDetermination.year_made
        )
      ) {
        return
      }

      const payload = {
        taxon_determination: {
          ...taxonDetermination,
          taxon_determination_object_id: this.metadata.object_id,
          taxon_determination_object_type: this.metadata.object_type
        }
      }

      TaxonDetermination.create(payload).then((response) => {
        TW.workbench.alert.create(
          'Taxon determination was successfully created.',
          'notice'
        )
        this.list.push(response.body)
      })
    },

    removeTaxonDetermination(determination) {
      this.removeItem(determination).then((_) => {
        TW.workbench.alert.create(
          'Taxon determination was successfully destroyed.',
          'notice'
        )
      })
    }
  }
}
</script>
