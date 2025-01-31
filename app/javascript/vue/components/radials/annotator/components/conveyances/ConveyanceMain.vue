<template>
  <div>
    <VSpinner
      v-if="isSaving"
      legend="Saving..."
    />
    <ConveyanceEdit
      v-if="currentConveyance"
      :conveyence="currentConveyance"
      @new="() => setConveyance(null)"
      @update="update"
    />
    <ConveyanceUpload
      v-else
      :object-id="objectId"
      :object-type="objectType"
      @add="addToList"
    />
    <ConveyanceList
      v-if="!currentConveyance"
      :list="list"
      @remove="removeItem"
      @select="setConveyance"
    />
  </div>
</template>

<script setup>
import { Conveyance } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { onBeforeMount, ref } from 'vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConveyanceList from './ConveyanceList.vue'
import ConveyanceUpload from './ConveyanceUpload.vue'
import ConveyanceEdit from './ConveyenceEdit.vue'

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

const isSaving = ref(false)
const currentConveyance = ref(null)
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

function setConveyance(conveyance) {
  currentConveyance.value = conveyance
}

function removeItem(item) {
  Conveyance.destroy(item.id)
    .then(() => {
      removeFromList(item)
    })
    .catch(() => {})
}

function update(conveyance) {
  console.log(conveyance)
  Conveyance.update(conveyance.id, {
    conveyance
  })
    .then(({ body }) => {
      setConveyance(null)
      removeFromList(body)

      TW.workbench.alert.create(
        'Conveyance was successfully updated.',
        'notice'
      )
    })
    .catch(() => {})
    .finally(() => {
      isSaving.value = false
    })
}

onBeforeMount(() => loadConveyance())
</script>
