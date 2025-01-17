<template>
  <div>
    <ConveyanceUpload
      :object-id="objectId"
      :object-type="objectType"
      @add="addToList"
    />
    <ConveyanceList
      :list="list"
      @remove="removeFromList"
    />
  </div>
</template>

<script setup>
import { Conveyance } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { onBeforeMount } from 'vue'
import ConveyanceList from './ConveyanceList.vue'
import ConveyanceUpload from './ConveyanceUpload.vue'

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

const { list, addToList, removeFromList } = useSlice({
  radialEmit: props.radialEmit
})

function loadConveyance() {
  Conveyance.where({
    conveyance_object_id: props.objectId,
    conveyance_object_type: props.objectType
  }).then(({ body }) => {
    list.value = body
  })
}

onBeforeMount(() => loadConveyance())
</script>
