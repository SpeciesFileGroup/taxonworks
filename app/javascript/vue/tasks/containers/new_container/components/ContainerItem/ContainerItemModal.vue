<template>
  <VModal
    v-if="isVisible"
    :container-style="{ 'overflow-y': 'unset' }"
    @close="isVisible = false"
  >
    <template #header>
      <h3>Container item</h3>
    </template>
    <template #body>
      <div>
        <p v-if="containerItem.objectId">{{ containerItem.label }}</p>

        <VAutocomplete
          v-else
          param="term"
          label="label"
          :url="TYPES[selectedType].autocomplete"
          :placeholder="TYPES[selectedType].placeholder"
          @get-item="setContainedObject"
        />
      </div>
    </template>
    <template #footer>
      <VBtn
        v-if="containerItem.objectId"
        :color="containerItem.id ? 'destroy' : 'primary'"
        medium
        @click="emit('destroy', containerItem)"
      >
        Remove
      </VBtn>
    </template>
  </VModal>
</template>

<script setup>
import { ref } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'

const TYPES = {
  [COLLECTION_OBJECT]: {
    autocomplete: '/collection_objects/autocomplete',
    placeholder: 'Search a collection object...'
  }
}

const emit = defineEmits(['add', 'destroy'])

const selectedType = ref(COLLECTION_OBJECT)
const isVisible = ref(false)
const containerItem = ref()

function show(data) {
  isVisible.value = true
  containerItem.value = {
    ...data
  }
}

function setContainedObject({ id, label }) {
  containerItem.value.objectId = id
  containerItem.value.objectType = selectedType.value
  containerItem.value.label = label
  isVisible.value = false

  emit('add', containerItem.value)
}

defineExpose({
  show
})
</script>
