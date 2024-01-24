<template>
  <BlockLayout>
    <template #header>
      <h3>Taxon determination</h3>
    </template>
    <template #body>
      <TaxonDetermination
        ref="taxonDeterminationRef"
        class="margin-medium-bottom"
        @on-add="determinationStore.add"
      />
      <TaxonDeterminationList
        v-model="determinationStore.determinations"
        v-model:lock="settings.locked.taxonDeterminations"
        @edit="editTaxonDetermination"
        @delete="determinationStore.remove"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref } from 'vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TaxonDetermination from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from '@/components/TaxonDetermination/TaxonDeterminationList.vue'
import useStore from '../store/determinations.js'
import useSettingStore from '../store/settings.js'

const settings = useSettingStore()
const determinationStore = useStore()

const taxonDeterminationRef = ref(null)

function editTaxonDetermination(item) {
  taxonDeterminationRef.value.setDetermination({
    id: item.id,
    uuid: item.uuid,
    global_id: item.global_id,
    otu_id: item.otu_id,
    day_made: item.day_made,
    month_made: item.month_made,
    year_made: item.year_made,
    position: item.position,
    roles_attributes: item?.determiner_roles || item.roles_attributes || []
  })
}
</script>
