<template>
  <div>
    <fieldset>
      <legend>Biological relationship</legend>
      <SmartSelector
        class="full_width"
        ref="smartSelector"
        model="biological_relationships"
        target="Otu"
        klass="Otu"
        pin-section="BiologicalRelationships"
        buttons
        inline
        label="name"
        pin-type="BiologicalRelationship"
        :custom-list="list"
        :lock-view="false"
        @selected="(item) => emit('select', item)"
      />
    </fieldset>
  </div>
</template>

<script setup>
import SmartSelector from '@/components/ui/SmartSelector'
import { ref } from 'vue'
import { BiologicalRelationship } from '@/routes/endpoints/BiologicalRelationship.js'

const emit = defineEmits(['select'])

const list = ref({
  all: []
})

BiologicalRelationship.all().then((response) => {
  list.value = { all: response.body }
})
</script>
