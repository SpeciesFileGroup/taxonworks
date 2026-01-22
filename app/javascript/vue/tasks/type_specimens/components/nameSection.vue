<template>
  <div class="panel type-specimen-box">
    <div class="header flex-separate middle">
      <h3>Taxon name</h3>
    </div>
    <div class="body">
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
    </div>
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import useStore from '../store/store.js'

const store = useStore()

function loadTypeMaterials(id) {
  store.loadTaxonName(id)
  store.loadTypeMaterials(id)
}
</script>
