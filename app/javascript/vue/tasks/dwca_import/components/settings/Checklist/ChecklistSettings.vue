<template>
  <h3>DwC Checklist Import Settings</h3>
  <div class="field">
    <CheckboxSetting
      v-for="(label, property) in CHECKLIST_CHECKBOX_SETTINGS"
      :key="property"
      :label="label"
      :property="property"
    />
  </div>
</template>

<script setup>
import CheckboxSetting from '../CheckboxSetting.vue'

const CHECKLIST_CHECKBOX_SETTINGS = {
  use_existing_taxon_hierarchy:
    'Taxon names without parentNameUsageID will match existing nomenclature instead of being children of Root'
}
</script>
