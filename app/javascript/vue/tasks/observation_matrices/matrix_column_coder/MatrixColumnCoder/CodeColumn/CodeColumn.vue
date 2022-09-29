<template>
  <div>
    <VBtn
      @click="showModal = true"
      color="primary"
      medium
    >
      Code column
    </VBtn>
    <VModal
      v-if="showModal"
      :container-style="{ width: '1000px' }"
      @close="showModal = false"
    >
      <template #header>
        <h3>Populate rows - {{ descriptor.title }}</h3>
      </template>
      <template #body>
        <div>
          <component
            :is="components[descriptor.type]"
            :descriptor="descriptor"
            v-model="observation"
          />
        </div>
      </template>
      <template #footer>
        <VBtn
          color="create"
          medium
          :disabled="isObservationEmpty"
          @click="handleClick"
        >
          Populate
        </VBtn>
      </template>
    </VModal>
    <VSpinner
      v-if="isPopulating"
      fullscreen
      legend="Populating rows..."
    />
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import ComponentName from '../../helpers/ComponentNames'
import FormContinuousDescriptorObservation from '../Form/FormContinuousDescriptorObservation.vue'
import FormSample from '../Form/FormSample.vue'
import FormFreeText from '../Form/FormFreeText.vue'
import FormPresenceAbsent from '../Form/FormPresenceAbsent.vue'
import FormQualitative from '../Form/FormQualitative.vue'
import populateRows from './populateRows'
import VSpinner from 'components/spinner.vue'

const components = {
  [ComponentName.Continuous]: FormContinuousDescriptorObservation,
  [ComponentName.Sample]: FormSample,
  [ComponentName.FreeText]: FormFreeText,
  [ComponentName.Presence]: FormPresenceAbsent,
  [ComponentName.Qualitative]: FormQualitative
}

const props = defineProps({
  descriptor: {
    type: Object,
    required: true
  },
  columnId: {
    type: Number,
    required: true
  }
})

const makeEmptyObservation = () => {
  const emptyObservation = {}

  if (props.descriptor.type === ComponentName.Qualitative) {
    Object.assign(emptyObservation, { characterStateId: [] })
  } else if (props.descriptor.type === ComponentName.Sample) {
    Object.assign(emptyObservation, { units: props.descriptor.defaultUnit })
  } else if (props.descriptor.type === ComponentName.Continuous) {
    Object.assign(emptyObservation, { continuousUnit: props.descriptor.defaultUnit })
  }

  return emptyObservation
}

const isPopulating = ref(false)
const showModal = ref(false)
const observation = ref(makeEmptyObservation())
const isObservationEmpty = computed(() => !Object.keys(observation.value).length)

const handleClick = () => {
  isPopulating.value = true

  populateRows({
    descriptorType: props.descriptor.type,
    columnId: props.columnId,
    observation: observation.value
  }).then(() => {
    isPopulating.value = false
    window.location.reload()
  })
}
</script>
