<template>
  <div>
    <fieldset>
      <legend>Geographic area</legend>
      <SmartSelector
        model="geographic_areas"
        label="name"
        :target="COLLECTING_EVENT"
        :klass="COLLECTING_EVENT"
        @selected="(item) => (geographicArea = item)"
      />
      <SmartSelectorItem
        label="name"
        :item="geographicArea"
        @unset="geographicArea = undefined"
      />
    </fieldset>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="!geographicArea"
      @click="update"
    >
      Update
    </VBtn>
  </div>
</template>

<script setup>
import SmartSelector from 'components/ui/SmartSelector.vue'
import SmartSelectorItem from 'components/ui/SmartSelectorItem.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import { COLLECTING_EVENT } from 'constants/index.js'
import { CollectingEvent } from 'routes/endpoints'
import { ref } from 'vue'

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  }
})

const geographicArea = ref()
const created = ref([])

function update() {
  const payload = {
    collecting_event_query: props.parameters,
    collecting_event: {
      geographic_area_id: geographicArea.value.id
    }
  }

  CollectingEvent.updateBatch(payload).then(({ body }) => {
    created.value = body
    TW.workbench.alert.create(
      `${body.length} collecting event items were successfully updated.`,
      'notice'
    )
  })
}
</script>
