<template>
  <div>
    <TaxonDeterminationForm @on-add="addDetermination" />
    <list-component
      :list="store.taxonDeterminations"
      @delete-index="removeTaxonDetermination"
      set-key="otu_id"
      label="object_tag"
    />
  </div>
</template>

<script setup>
import useStore from '../../store/store.js'
import useLockStore from '../../store/lock.js'
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import ListComponent from '@/components/displayList'

const store = useStore()
const lock = useLockStore()

function addDetermination(taxonDetermination) {
  if (
    !store.taxonDeterminations.find(
      (determination) => determination.otu_id === taxonDetermination.otu_id
    )
  ) {
    store.taxon_determinations_attributes.push(taxonDetermination)
  }
}

function removeTaxonDetermination(index) {
  store.taxonDeterminations.splice(index, 1)
}
</script>
