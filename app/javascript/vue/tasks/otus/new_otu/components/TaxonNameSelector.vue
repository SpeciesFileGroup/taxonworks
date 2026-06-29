<template>
  <BlockLayout>
    <template #header>
      <h3>Taxon name</h3>
    </template>
    <template #body>
      <div class="width-30">
        <VSwitch
          v-model="matchView"
          :options="OPTIONS"
        />
        <VAutocomplete
          v-if="!isMatch && !taxonName"
          class="margin-medium-top margin-medium-bottom"
          placeholder="Search a taxon name..."
          url="/taxon_names/autocomplete"
          param="term"
          label="label_html"
          clear-after
          @get-item="loadTaxonName"
        />
        <SmartSelectorItem
          v-if="taxonName"
          :item="taxonName"
          :label="object_tag"
          @unset="taxonName = null"
        />
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { TaxonName } from '@/routes/endpoints'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VSwitch from '@/components/ui/VSwitch.vue'
import { computed } from 'vue'

const isMatch = defineModel('match', {
  type: Boolean,
  required: true
})

const taxonName = defineModel({
  type: [Object, null],
  required: true
})

const OPTIONS = ['Match', 'Select']

const matchView = computed({
  get: () => (isMatch.value ? OPTIONS[0] : OPTIONS[1]),
  set: (value) => {
    isMatch.value = value === OPTIONS[0]
  }
})

function loadTaxonName({ id }) {
  TaxonName.find(id).then(({ body }) => {
    taxonName.value = body
  })
}
</script>
