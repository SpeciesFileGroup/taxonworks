<template>
  <BlockLayout>
    <template #header>
      <h3>Taxon name</h3>
    </template>
    <template #body>
      <div class="field">
        <label>Species name</label>
        <VAutocomplete
          class="types_field"
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          display="label"
          min="2"
          :add-params="{
            'type[]': 'Protonym',
            'nomenclature_group[]': 'SpeciesGroup'
          }"
          @select="({ id }) => loadTypeMaterials(id)"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import useStore from '../store/store.js'
import useSettingStore from '../store/settings.js'

const store = useStore()
const settings = useSettingStore()

async function loadTypeMaterials(id) {
  settings.isLoading = true

  try {
    await Promise.all([store.loadTaxonName(id), store.loadTypeMaterials(id)])
  } catch {
  } finally {
    settings.isLoading = false
  }
}
</script>
