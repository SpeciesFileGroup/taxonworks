<template>
  <BlockLayout>
    <template #header>
      <h3>Taxon determination</h3>
    </template>
    <template #body>
      <TaxonDetermination
        @on-add="addDetermination"
      />
        <TaxonDeterminationList
          v-model="list"
          v-model:lock="locked.taxonDeterminations"
          @sort="updateLastChange"
          @delete="determinationStore.remove"
        />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TaxonDetermination from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from '@/components/TaxonDetermination/TaxonDeterminationList.vue'
import useStore from '../store/determinations';

const determinationStore = useStore()

function addDetermination(determination) {
  determinationStore.determinations.push({
    ...determination,
    isUnsaved: true
  })
}

</script>
