<template>
  <BlockLayout :warning="!isFilled">
    <template #header>
      <h3>Taxon determination</h3>
    </template>
    <template #options>
      <VIcon
        v-if="!isFilled"
        color="attention"
        name="attention"
        small
        title="You need to fill out this form in order to save"
      />
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
        @delete="removeDetermination"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import TaxonDetermination from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'
import TaxonDeterminationList from '@/components/TaxonDetermination/TaxonDeterminationList.vue'
import useStore from '../store/determinations.js'
import useSettingStore from '../store/settings.js'
import VIcon from '@/components/ui/VIcon/index.vue'

const settings = useSettingStore()
const determinationStore = useStore()

const taxonDeterminationRef = ref(null)

const isFilled = computed(
  () =>
    determinationStore.determinations.length || determinationStore.hasUnsaved
)

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

function removeDetermination(determination) {
  if (
    determinationStore.determinations.filter((d) => d.id).length === 1 &&
    determination.id
  ) {
    TW.workbench.alert.create(
      'You cannot delete this record, at least one taxon determination saved is required.',
      'error'
    )
  } else if (
    !determination.id ||
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    determinationStore.remove(determination)
  }
}

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const id = urlParams.get('otu_id')

  if (/^\d+$/.test(id)) {
    taxonDeterminationRef.value.setDetermination({ otu_id: id })
  }
})
</script>
