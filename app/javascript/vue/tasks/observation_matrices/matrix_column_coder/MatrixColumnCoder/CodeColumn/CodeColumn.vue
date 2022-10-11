<template>
  <div>
    <VBtn
      @click="showModal = true"
      color="primary"
      medium
    >
      Populate column
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
          Code
        </VBtn>
      </template>
    </VModal>
    <VSpinner
      v-if="isPopulating"
      fullscreen
      legend="Populating rows..."
    />
    <ConfirmationModal ref="confirmationModal" />
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
import ConfirmationModal from 'components/ConfirmationModal.vue'

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
const confirmationModal = ref(null)
const observation = ref(makeEmptyObservation())
const isObservationEmpty = computed(() => !Object.keys(observation.value).length)

const handleClick = async () => {
  const ok = await confirmationModal.value.show({
    title: 'Populate column',
    message: 'Are you sure you want to proceed?',
    confirmationWord: 'POPULATE',
    okButton: 'Create',
    cancelButton: 'Cancel',
    typeButton: 'submit'
  })

  if (!ok) { return }

  isPopulating.value = true

  populateRows({
    descriptorType: props.descriptor.type,
    columnId: props.columnId,
    observation: observation.value
  }).then(async ({ failed, passed, exists }) => {
    isPopulating.value = false

    await confirmationModal.value.show({
      title: 'Result',
      message: `Passed: ${passed}<br>Failed: ${failed}<br>Exists: ${exists}`,
      okButton: 'OK',
      typeButton: 'default'
    })

    window.location.reload()
  })
}
</script>
