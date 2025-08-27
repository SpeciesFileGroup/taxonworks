<template>
  <fieldset>
    <legend>Biological relationship</legend>
    <SmartSelector
      model="biological_relationships"
      :target="BIOLOGICAL_ASSOCIATION"
      :klass="BIOLOGICAL_ASSOCIATION"
      pin-section="BiologicalRelationships"
      buttons
      inline
      label="name"
      :pin-type="BIOLOGICAL_RELATIONSHIP"
      :custom-list="{ all }"
      :lock-view="false"
      @selected="(item) => emit('select', item)"
    />
  </fieldset>
</template>

<script setup>
import { BiologicalRelationship } from '@/routes/endpoints'
import {
  BIOLOGICAL_ASSOCIATION,
  BIOLOGICAL_RELATIONSHIP,
  FIELD_OCCURRENCE
} from '@/constants'
import { ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector'

const all = ref([])

const emit = defineEmits(['select'])

BiologicalRelationship.all().then(({ body }) => {
  all.value = body
})
</script>
