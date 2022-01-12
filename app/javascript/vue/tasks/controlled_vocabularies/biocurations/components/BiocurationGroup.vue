<template>
  <div class="panel">
    <div class="content">
      <h3>{{ biocurationGroup.object_label }}</h3>
      <hr>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Tag } from 'routes/endpoints'

const props = defineProps({
  biocurationGroup: {
    type: Object,
    required: true
  }
})

const createdBiologicalClassIds = ref()

Tag.where({ keyword_id: props.biocurationGroup.id }).then(({ body }) => {
  createdBiologicalClassIds.value = body
})
</script>
