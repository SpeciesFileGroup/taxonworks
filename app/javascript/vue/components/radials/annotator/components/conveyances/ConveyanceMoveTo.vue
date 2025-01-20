<template>
  <div class="separate-top separate-bottom">
    <h4>Move to</h4>
    <ul class="no_bullets">
      <li
        v-for="({ label }, type) in OBJECT_TYPES"
        :key="type"
      >
        <label>
          <input
            type="radio"
            name="conveyance-type"
            v-model="selectedType"
            :value="type"
          />
          {{ label }}
        </label>
      </li>
    </ul>
    <div
      v-if="selectedType && !selectedObject"
      class="separate-top"
    >
      <VAutocomplete
        v-if="selectedType.value != OTU"
        :url="OBJECT_TYPES[selectedType].url"
        :placeholder="`Select a ${OBJECT_TYPES[
          selectedType
        ].label.toLowerCase()}`"
        label="label_html"
        clear-after
        param="term"
        @get-item="(item) => (selectedObject = makePayload(item))"
      />
      <OtuPicker
        v-else
        clear-after
        @get-item="(item) => (selectedObject = makePayload(item))"
      />
    </div>
    <SmartSelectorItem
      v-if="selectedObject"
      :item="selectedObject"
      label="label"
      @unset="() => (selectedObject = undefined)"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import OtuPicker from '@/components/otu/otu_picker/otu_picker'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import { OTU, FIELD_OCCURRENCE, COLLECTION_OBJECT } from '@/constants'

const OBJECT_TYPES = {
  [OTU]: {
    label: 'Otu',
    url: '/otus/autocomplete'
  },
  [COLLECTION_OBJECT]: {
    label: 'Collection object',
    url: '/collection_objects/autocomplete'
  },
  [FIELD_OCCURRENCE]: {
    label: 'Taxon name',
    url: '/taxon_names/autocomplete'
  }
}

const selectedType = ref()

const selectedObject = defineModel({
  type: Object,
  default: undefined
})

function makePayload(item) {
  return {
    id: item.id,
    label: item.label_html || item.object_tag,
    type: selectedType.value
  }
}
</script>
