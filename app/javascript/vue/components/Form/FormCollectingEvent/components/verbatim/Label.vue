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
    <button
      type="button"
      class="button normal-input button-default"
      :disabled="!collectingEvent.verbatim_label"
      @click="parseData"
    >
      Parse fields
    </button>
  </div>
</template>

<script setup>
import { CollectingEvent } from '@/routes/endpoints'

const collectingEvent = defineModel({
  type: Object,
  requierd: true
})

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
