<template>
  <div class="field label-above">
    <label>Label</label>
    <textarea
      class="full_width"
      rows="5"
      v-model="collectingEvent.verbatim_label"
      @change="
        () => {
          collectingEvent.isUnsaved = true
        }
      "
    />
    <div class="horizontal-left-content gap-small">
      <VBtn
        color="primary"
        medium
        :disabled="!collectingEvent.verbatim_label"
        @click="parseData"
      >
        Parse fields
      </VBtn>
      <CloneLabel
        v-if="bufferedCollectingEvent"
        v-model="collectingEvent"
        :buffered-collecting-event="bufferedCollectingEvent"
      />
    </div>
  </div>
</template>

<script setup>
import { inject } from 'vue'
import { CollectingEvent } from '@/routes/endpoints'
import CloneLabel from './CloneLabel.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const collectingEvent = defineModel({
  type: Object,
  requierd: true
})

const bufferedCollectingEvent = inject('bufferedCollectingEvent')

function parseData() {
  const payload = {
    verbatim_label: collectingEvent.value.verbatim_label
  }

  CollectingEvent.parseVerbatimLabel(payload).then(({ body }) => {
    if (body) {
      const parsedFields = Object.assign(
        {},
        body.date,
        body.geo.verbatim,
        body.elevation,
        body.collecting_method
      )

      collectingEvent.value = {
        ...collectingEvent.value,
        ...parsedFields,
        isUnsaved: true
      }

      TW.workbench.alert.create('Label value parsed.', 'notice')
    } else {
      TW.workbench.alert.create('No label value to convert.', 'error')
    }
  })
}
</script>
