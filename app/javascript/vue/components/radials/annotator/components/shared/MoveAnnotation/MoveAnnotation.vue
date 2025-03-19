<template>
  <div>
    <VBtn
      color="primary"
      circle
      @click="() => (isModalVisible = true)"
    >
      <VIcon
        name="swap"
        x-small
      />
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ overflowY: 'visible' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Move to</h3>
      </template>
      <template #body>
        <ul class="no_bullets">
          <template
            v-for="({ label, annotations }, type) in OBJECT_TYPES"
            :key="type"
          >
            <li v-if="annotations.includes(annotation.base_class)">
              <label>
                <input
                  type="radio"
                  name="depiction-type"
                  v-model="selectedType"
                  :value="type"
                />
                {{ label }}
              </label>
            </li>
          </template>
        </ul>

        <VAutocomplete
          v-if="selectedType && !selectedObject"
          class="margin-medium-top"
          :url="OBJECT_TYPES[selectedType].url"
          :placeholder="`Select a ${OBJECT_TYPES[
            selectedType
          ].label.toLowerCase()}`"
          label="label_html"
          clear-after
          param="term"
          @get-item="setSelectedObject"
        />

        <SmartSelectorItem
          v-if="selectedObject"
          :item="selectedObject"
          label="label"
          @unset="() => (selectedObject = null)"
        />
        <VBtn
          class="margin-medium-top"
          color="update"
          :disabled="!selectedType || !selectedObject"
          @click="moveObject"
        >
          Move
        </VBtn>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { OBJECT_TYPES } from './types'
import { Annotation } from '@/routes/endpoints'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import * as services from '@/routes/endpoints'

const props = defineProps({
  annotation: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['move'])

const isModalVisible = ref(false)
const selectedObject = ref(null)
const selectedType = ref(null)

function makeObject(item) {
  return {
    ...item,
    label: item.label_html || item.object_tag
  }
}

function moveObject() {
  const payload = {
    annotation_global_id: props.annotation.global_id,
    to_global_id: selectedObject.value.global_id
  }

  Annotation.moveOne(payload)
    .then(({ body }) => {
      emit('move', body)
      isModalVisible.value = false
      TW.workbench.alert.create('Annotation was successfully moved.', 'notice')
    })
    .catch(() => {})
}

function setSelectedObject(item) {
  services[selectedType.value].find(item.id).then(({ body }) => {
    selectedObject.value = makeObject(body)
  })
}

watch(selectedType, () => (selectedObject.value = null))
</script>
