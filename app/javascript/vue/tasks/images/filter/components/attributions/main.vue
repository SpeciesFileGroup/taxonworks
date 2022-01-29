<template>
  <div>
    <v-btn
      color="primary"
      medium
      :disabled="!ids.length"
      @click="activeModal = true"
    >
      Attribution
    </v-btn>
    <v-modal
      v-if="activeModal"
      @close="activeModal = false"
      :container-style="{ width: '600px' }"
    >
      <template #header>
        <h3>Attribution</h3>
      </template>
      <template #body>
        <attribution-component
          :type="type"
          @attribution="createAttribution"/>
      </template>
    </v-modal>

    <spinner-component
      v-if="isSaving"
      full-screen
      legend="Creating attributions..."
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Attribution } from 'routes/endpoints'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import AttributionComponent from './attributions.vue'
import SpinnerComponent from 'components/spinner.vue'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  type: {
    type: String,
    required: true
  }
})

const activeModal = ref(false)
const isSaving = ref(false)

const createAttribution = attribution => {
  const requests = props.ids.map(id => Attribution.create({
    attribution: {
      ...attribution,
      attribution_object_type: props.type,
      attribution_object_id: id
    }
  }))

  isSaving.value = true

  Promise.allSettled(requests).then(_ => {
    isSaving.value = false
    activeModal.value = false
    TW.workbench.alert.create('Attributions were successfully created.', 'notice')
  })
}

</script>
