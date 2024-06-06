<template>
  <AttributionComponent
    :type="type"
    @attribution="createAttribution"
  />
  <VSpinner
    v-if="isSaving"
    legend="Creating attributions..."
  />
  <ConfirmationModal
    ref="confirmationModalRef"
    :container-style="{ 'min-width': 'auto', width: '300px' }"
  />
</template>

<script setup>
import { ref } from 'vue'
import { Attribution } from '@/routes/endpoints'
import AttributionComponent from './attributions.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import confirmationOpts from '../../../constants/confirmationOpts.js'

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  }
})

const isSaving = ref(false)
const confirmationModalRef = ref(null)

async function createAttribution(attribution) {
  const ok = await confirmationModalRef.value.show(confirmationOpts)

  if (ok) {
    const promises = props.ids.map((id) => {
      const payload = {
        ...attribution,
        attribution_object_type: props.objectType,
        attribution_object_id: id
      }

      return Attribution.create({ attribution: payload })
    })

    isSaving.value = true

    Promise.allSettled(promises).then(() => {
      TW.workbench.alert.create(
        'Attribution item(s) were successfully created',
        'notice'
      )
      isSaving.value = false
    })
  }
}
</script>
