<template>
  <BlockLayout>
    <template #header>
      <h3>Taxon determination</h3>
    </template>
    <template #body>
      <TaxonDetermination />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TaxonDetermination from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
</script>
