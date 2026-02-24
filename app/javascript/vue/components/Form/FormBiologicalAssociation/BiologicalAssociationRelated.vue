<template>
  <fieldset>
    <legend>Related</legend>
    <VSwitch
      :options="Object.keys(TAB)"
      v-model="tabSelected"
    />

    <SmartSelector
      v-bind="TAB[tabSelected]"
      ref="smartSelector"
      :target="target"
      :klass="BIOLOGICAL_ASSOCIATION"
      :params="params"
      @selected="(item) => emit('select', item)"
    />
  </fieldset>
</template>

<script setup>
import VSwitch from '@/components/ui/VSwitch.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import { OTU, COLLECTION_OBJECT, FIELD_OCCURRENCE } from '@/constants'
import { ref, useTemplateRef } from 'vue'

defineProps({
  target: {
    type: String,
    required: true
  },

  params: {
    type: Object,
    default: () => ({
      ba_target: 'object'
    })
  }
})

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

const smartSelectorRef = useTemplateRef('smartSelector')
const tabSelected = ref(OTU)

function setFocus() {
  smartSelectorRef.value?.setFocus()
}

defineExpose({
  setFocus
})
</script>
