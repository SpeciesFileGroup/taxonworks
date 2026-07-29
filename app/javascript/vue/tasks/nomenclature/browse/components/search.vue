<template>
  <div>
    <AutocompletePopover
      title="Search a taxon name to browse"
      class="vue-autocomplete"
      input-class="mousetrap"
      url="/taxon_names/autocomplete"
      placeholder="Select a taxon name"
      autofocus
      param="term"
      display="label"
      label="label_html"
      @select="redirect"
    >
      <template #bottom>
        <label>
          <input
            v-model="validName"
            type="checkbox"
          />
          Redirect to valid name
        </label>
      </template>
    </AutocompletePopover>
  </div>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { useHotkey, useUserPreference } from '@/composables'
import { ref, onMounted } from 'vue'
import { getPlatformKey } from '@/helpers'
import AutocompletePopover from '@/components/ui/Autocomplete/AutocompletePopover.vue'

const autocomplete = ref(null)

const shortcuts = ref([
  {
    keys: [getPlatformKey(), 'f'],
    preventDefault: true,
    handler() {
      autocomplete.value?.setFocus()
    }
  }
])

useHotkey(shortcuts.value)

const STORAGE_KEY_REDIRECT_VALID = 'browseNomenclature::redirectValid'

const validName = useUserPreference(STORAGE_KEY_REDIRECT_VALID, true)

onMounted(() => {
  TW.workbench.keyboard.createLegend('Alt+f', 'Search', 'Browse nomenclature')
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
