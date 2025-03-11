<template>
  <div>
    <VSpinner
      v-if="isSaving"
      legend="Saving..."
    />
    <ConveyanceEdit
      v-if="currentConveyance"
      :conveyance="currentConveyance"
      @new="() => setConveyance(null)"
      @update="update"
      @update:sound="updateSound"
    />
    <SmartSelector
      v-else
      model="sounds"
      :autocomplete="false"
      :search="false"
      :target="objectType"
      :add-tabs="['new']"
      :pin-type="SOUND"
      pin-section="Sounds"
      @selected="createConveyance"
    >
      <template #new>
        <ConveyanceUpload
          :object-id="objectId"
          :object-type="objectType"
          @add="addToList"
        />
      </template>
    </SmartSelector>

    <ConveyanceList
      v-if="!currentConveyance"
      :list="list"
      @remove="removeItem"
      @select="setConveyance"
    />
  </div>
</template>

<script setup>
import { Conveyance, Sound } from '@/routes/endpoints'
import { useSlice } from '@/components/radials/composables'
import { onBeforeMount, ref } from 'vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConveyanceList from './ConveyanceList.vue'
import ConveyanceUpload from './ConveyanceUpload.vue'
import ConveyanceEdit from './ConveyenceEdit.vue'
import { SOUND } from '@/constants'

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

function createConveyance(item) {
  const payload = {
    conveyance: {
      conveyance_object_id: props.objectId,
      conveyance_object_type: props.objectType,
      sound_id: item.id
    }
  }

  Conveyance.create(payload)
    .then(({ body }) => {
      addToList(body)
      TW.workbench.alert.create(
        'Conveyance was successfully created.',
        'notice'
      )
    })
    .catch(() => {})
}

function setConveyance(conveyance) {
  currentConveyance.value = conveyance
}

async function updateSound({ conveyanceId, soundId, name }) {
  try {
    const payload = {
      sound: {
        name
      }
    }

    isSaving.value = true

    await Sound.update(soundId, payload)
    addToList((await Conveyance.find(conveyanceId)).body)
    currentConveyance.value.sound.name = name
  } catch {}

  isSaving.value = false
  TW.workbench.alert.create('Sound was successfully updated.', 'notice')
}

function removeItem(item) {
  Conveyance.destroy(item.id)
    .then(() => {
      removeFromList(item)
    })
    .catch(() => {})
}

function update(conveyance) {
  Conveyance.update(conveyance.id, {
    conveyance
  })
    .then(({ body }) => {
      setConveyance(null)
      if (conveyance.conveyance_object_id) {
        removeFromList(body)
      } else {
        addToList(body)
      }

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
