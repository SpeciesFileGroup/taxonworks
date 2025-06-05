<template>
  <div>
    <button
      class="button normal-input button-default"
      @click="() => setModalView(true)"
    >
      Parse from
    </button>
    <modal-component
      v-if="isModalVisible"
      @close="() => setModalView(false)"
      :container-style="{ width: '800px' }"
    >
      <template #header>
        <h3>Parse collection object buffered data</h3>
      </template>
      <template #body>
        <SmartSelector
          model="collection_objects"
          :target="COLLECTING_EVENT"
          @selected="parseData"
        />
      </template>
    </modal-component>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { COLLECTING_EVENT } from '@/constants'
import { CollectingEvent } from '@/routes/endpoints'
import ModalComponent from '@/components/ui/Modal'
import SmartSelector from '@/components/ui/SmartSelector'

const emit = defineEmits(['parse'])

const isModalVisible = ref(false)

function parseData(co) {
  CollectingEvent.parseVerbatimLabel({
    verbatim_label: co.buffered_collecting_event
  }).then(({ body }) => {
    if (body) {
      const parsedFields = Object.assign(
        {},
        body.date,
        body.geo.verbatim,
        body.elevation,
        body.collecting_method
      )

      emit('parse', parsedFields)

      TW.workbench.alert.create('Buffered value parsed.', 'notice')
      setModalView(false)
    } else {
      TW.workbench.alert.create('No buffered value to convert.', 'error')
    }
  })
}

function setModalView(value) {
  isModalVisible.value = value
}
</script>
