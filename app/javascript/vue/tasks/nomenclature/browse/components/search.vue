<template>
  <div>
    <br />
    <VAutocomplete
      class="vue-autocomplete"
      url="/taxon_names/autocomplete"
      placeholder="Select a taxon name"
      autofocus
      param="term"
      display="label"
      label="label_html"
      @get-item="redirect"
    />
    <label>
      <input
        v-model="validName"
        type="checkbox"
      />
      Redirect to valid name
    </label>
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete'
import { RouteNames } from '@/routes/routes'
import { ref, watch, onMounted } from 'vue'

const SettingsStore = {
  redirectValid: 'browseNomenclature::redirectValid'
}

const validName = ref(true)

watch(validName, (newVal) => {
  sessionStorage.setItem(SettingsStore.redirectValid, newVal)
})

onMounted(() => {
  const value = sessionStorage.getItem(SettingsStore.redirectValid)
  if (value !== null) {
    validName.value = value === 'true'
  }
})

function redirect(event) {
  window.open(
    `${RouteNames.BrowseNomenclature}?taxon_name_id=${
      validName.value ? event.valid_taxon_name_id : event.id
    }`,
    '_self'
  )
}
</script>

<style scoped>
.vue-autocomplete {
  width: 300px;
}
:deep(.vue-autocomplete-list) {
  min-width: 800px;
}
</style>
