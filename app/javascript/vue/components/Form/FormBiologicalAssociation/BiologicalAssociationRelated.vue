<template>
  <fieldset>
    <legend>Related</legend>
    <VSwitch
      :options="Object.keys(TAB)"
      v-model="tabSelected"
    />

    <SmartSelector
      v-bind="TAB[tabSelected]"
      :target="FIELD_OCCURRENCE"
      buttons
      inline
      @selected="(item) => emit('select', item)"
    />
  </fieldset>
</template>

<script setup>
import VSwitch from '@/components/ui/VSwitch.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import { OTU, COLLECTION_OBJECT, FIELD_OCCURRENCE } from '@/constants'
import { ref } from 'vue'

const TAB = {
  [OTU]: {
    model: 'otus',
    otuPicker: true,
    autocomplete: false
  },
  [COLLECTION_OBJECT]: { model: 'collection_objects' },
  [FIELD_OCCURRENCE]: { model: 'field_occurrences' }
}

const emit = defineEmits(['select'])

const tabSelected = ref(OTU)
</script>
