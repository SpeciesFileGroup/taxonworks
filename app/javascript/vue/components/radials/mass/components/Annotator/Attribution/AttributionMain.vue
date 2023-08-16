<template>
  <attribution-component
    :type="type"
    @attribution="createAttribution"
  />
  <VSpinner
    v-if="isSaving"
    legend="Creating attributions..."
  />
</template>

<script setup>
import { ref } from 'vue'
import { Attribution } from '@/routes/endpoints'
import AttributionComponent from './attributions.vue'
import VSpinner from '@/components/spinner.vue'

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

function createAttribution(attribution) {
  const promises = props.ids.map((id) => {
    const payload = {
      ...attribution,
      attribution_object_type: props.objectType,
      attribution_object_id: id
    }

    return Attribution.create({ attribution: payload })
  })

  isSaving.value = true

  Promise.allSettled(promises).then((_) => {
    TW.workbench.alert.create(
      'Attribution item(s) were successfully created',
      'notice'
    )
    isSaving.value = false
  })
}
</script>
