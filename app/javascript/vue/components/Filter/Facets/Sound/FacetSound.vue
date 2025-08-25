<template>
  <FacetContainer>
    <h3>Sounds</h3>
    <SmartSelector
      model="sounds"
      :target="target"
      @selected="addToArray(list, $event)"
    />
    <DisplayList
      :list="list"
      label="object_tag"
      :delete-warning="false"
      soft-delete
      @delete="removeFromArray(list, $event)"
    />
  </FacetContainer>
</template>

<script setup>
import { ref, watch } from 'vue'
import { addToArray, removeFromArray } from '@/helpers/arrays'
import { Sound } from '@/routes/endpoints'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import DisplayList from '@/components/displayList.vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

defineProps({
  target: {
    type: String,
    required: true
  }
})

const params = defineModel({
  type: Object,
  required: true
})

const list = ref([])
const soundIds = params.value.sound_id || []

if (soundIds.length) {
  Sound.all({ sound_id: soundIds }).then(({ body }) => {
    list.value = body
  })
}

watch(
  list,
  (newVal) => {
    params.value.sound_id = newVal.map((co) => co.id)
  },
  { deep: true }
)

watch(
  () => params.value.sound_id,
  (newVal, oldVal) => {
    if (!newVal?.length && oldVal?.length) {
      list.value = []
    }
  }
)
</script>
