<template>
  <div>
    <VBtn
      color="primary"
      medium
      @click="setModalView(true)"
    >
      Gazetteer
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{
        width: '60vw',
        maxWidth: '900px',
        minWidth: '540px'
      }"
      @close="setModalView(false)"
    >
      <template #header>
        <h3>Gazetteer</h3>
      </template>
      <template #body>
        <SmartSelector
          v-model="gazetteer"
          model="gazetteers"
          label="name"
          pin-section="Gazetteers"
          pin-type="Gazetteer"
          :add-tabs="['map']"
          buttons
          inline
          @selected="setGazetteer"
        >
          <template #map>
            <MapShapePicker
              :shape-endpoint="Gazetteer"
              @select="setGazetteer"
            />
          </template>
        </SmartSelector>
        <SmartSelectorItem
          v-if="gazetteer?.id"
          class="margin-medium-top"
          :item="gazetteer"
          label="name"
          @unset="gazetteer = null"
        />
      </template>
      <template #footer>
        <VBtn
          color="primary"
          medium
          :disabled="!gazetteer?.id"
          @click="createShape"
        >
          Add
        </VBtn>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import MapShapePicker from '@/components/ui/SmartSelector/MapShapePicker.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import { Gazetteer } from '@/routes/endpoints'
import { GEOREFERENCE_GAZETTEER } from '@/constants/index.js'
import { randomUUID } from '@/helpers'
import { ref } from 'vue'

const emit = defineEmits(['create'])

const isModalVisible = ref(false)
const gazetteer = ref(null)

function createShape() {
  emit('create', {
    uuid: randomUUID(),
    gazetteer_id: gazetteer.value.id,
    geo_json: gazetteer.value.shape,
    type: GEOREFERENCE_GAZETTEER
  })

  setModalView(false)
}

function resetShape() {
  gazetteer.value = null
}

function setModalView(value) {
  if (!value) {
    resetShape()
  }

  isModalVisible.value = value
}

function setGazetteer(item) {
  Gazetteer.find(item.id, { embed: ['shape'] }).then(({ body }) => {
    gazetteer.value = body
  })
}
</script>
