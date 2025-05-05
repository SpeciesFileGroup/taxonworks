<template>
  <fieldset class="full_width">
    <legend>Related</legend>
    <VSwitch
      class="margin-small-bottom"
      :options="Object.keys(TABS)"
      v-model="tab"
      name="related"
    />
    <SmartSelector
      class="full_width"
      :target="BIOLOGICAL_ASSOCIATION"
      :klass="BIOLOGICAL_ASSOCIATION"
      v-bind="TABS[tab]"
      @selected="sendRelated"
    />
  </fieldset>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import VSwitch from '@/components/ui/VSwitch.vue'
import { BIOLOGICAL_ASSOCIATION, COLLECTION_OBJECT, OTU } from '@/constants'
import { ref } from 'vue'

const TABS = {
  [OTU]: {
    model: 'otus',
    pinSection: 'Otus',
    pinType: OTU,
    otuPicker: true,
    autocomplete: false
  },
  [COLLECTION_OBJECT]: {
    model: 'collection_objects',
    pinSection: 'CollectionObjects',
    pinType: COLLECTION_OBJECT
  }
}

const emit = defineEmits(['select'])

const tab = ref(OTU)

function sendRelated(item) {
  item.type = item.base_class
  emit('select', item)
}
</script>
