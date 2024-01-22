<template>
  <BlockLayout>
    <template #header>
      <h3>Taxon determination</h3>
    </template>
    <template #body>
      <TaxonDetermination
        class="margin-medium-bottom"
        @on-add="determinationStore.add"
      />
      <TaxonDeterminationList
        v-model="determinationStore.determinations"
        v-model:lock="settings.locked.taxonDeterminations"
        @delete="determinationStore.remove"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TaxonDetermination from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from '@/components/TaxonDetermination/TaxonDeterminationList.vue'
import useStore from '../store/determinations.js'
import useSettingStore from '../store/settings.js'

const settings = useSettingStore()
const determinationStore = useStore()
</script>
