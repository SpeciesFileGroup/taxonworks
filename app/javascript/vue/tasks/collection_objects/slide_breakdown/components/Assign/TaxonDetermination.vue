<template>
  <div>
    <TaxonDeterminationForm @onAdd="addDetermination"/>
    <list-component
      :list="collectionObject.taxon_determinations_attributes"
      @delete="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script>

import TaxonDeterminationForm from 'components/TaxonDetermination/TaxonDeterminationForm.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import ListComponent from 'components/displayList'
import SharedComponent from '../shared/lock.js'

export default {
  mixins: [SharedComponent],

  components: {
    ListComponent,
    TaxonDeterminationForm
  },

  computed: {
    collectionObject: {
      get () {
        return this.$store.getters[GetterNames.GetCollectionObject]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectionObject, value)
      }
    }
  },

  methods: {
    addDetermination (taxonDetermination) {
      if (
        this.collectionObject.taxon_determinations_attributes.find(determination => determination.otu_id === taxonDetermination.otu_id)
      ) { return }

      this.collectionObject.taxon_determinations_attributes.push(taxonDetermination)
    },

    removeTaxonDetermination (determination) {
      const index = this.collectionObject.taxon_determinations_attributes.findIndex(item => JSON.stringify(item) === JSON.stringify(determination))

      this.collectionObject.taxon_determinations_attributes.splice(index, 1)
    }
  }
}
</script>
