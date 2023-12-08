<template>
  <div>
    <div class="flex-separate middle">
      <h3>Taxon determination</h3>
    </div>
    <TaxonDeterminationForm @on-add="addDetermination">
      <template #footer-right>
        <VLock v-model="lock.taxonDeterminations" />
      </template>
    </TaxonDeterminationForm>
    <list-component
      :list="store.taxonDeterminations"
      @delete-index="removeTaxonDetermination"
      soft-delete
      :warning="false"
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
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()
const lock = useLockStore()

function addDetermination(taxonDetermination) {
  store.addDetermination(taxonDetermination)
}

function removeTaxonDetermination(index) {
  store.taxonDeterminations.splice(index, 1)
}
</script>
