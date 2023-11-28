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

function addDetermination(taxonDetermination) {
  store.addDetermination(taxonDetermination)
}

function removeTaxonDetermination(index) {
  store.taxonDeterminations.splice(index, 1)
}
</script>
