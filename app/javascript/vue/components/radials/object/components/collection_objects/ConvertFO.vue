<template>
  <div>
    <ConvertToFoButton
      :collection-object="co"
      @delete="() => removeFromList(co)"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import ConvertToFoButton from './ConvertToFoButton.vue'

const props = defineProps({
  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  radialEmit: {
    type: Object,
    required: true
  }
})

const co = ref()

const { removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

CollectionObject.find(props.objectId).then(({ body }) => {
  co.value = body
})
</script>
