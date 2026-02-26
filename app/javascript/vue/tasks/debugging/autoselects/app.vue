<template>
  <div id="autoselects_task">
    <h1>Autoselect Playground</h1>
    <p>A prototype task for testing autoselect field behavior across models.</p>

    <section
      v-for="model in registeredModels"
      :key="model.url"
      class="separate-bottom"
    >
      <h2>{{ model.label }}</h2>
      <AutoselectField
        :url="model.url"
        :param="model.param"
        :placeholder="`Search ${model.label}...`"
        @select="onSelect(model.label, $event)"
      />
      <pre v-if="selections[model.label]">{{ JSON.stringify(selections[model.label], null, 2) }}</pre>
    </section>

    <p v-if="registeredModels.length === 0" class="feedback">
      No models registered yet. Run <code>rails generate taxon_works:autoselect &lt;model_name&gt;</code> to add one.
    </p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import AutoselectField from '@/components/ui/AutoselectField.vue'

// Models are registered here by the autoselect generator.
// Each entry added by `rails generate taxon_works:autoselect <model_name>`
const registeredModels = ref([
  { url: '/taxon_names/autoselect', param: 'taxon_name_id', label: 'TaxonName' },
  { url: '/otus/autoselect', param: 'otu_id', label: 'OTU' },
])

const selections = ref({})

function onSelect(label, values) {
  selections.value[label] = values
}
</script>
