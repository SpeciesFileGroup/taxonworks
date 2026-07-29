<template>
  <VModal
    v-if="isModalVisible"
    @close="close"
  >
    <template #header>
      <h3>Serial</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isSaving"
        legend="Saving..."
      />
      <FormSerial
        class="margin-medium-bottom"
        v-model="serial"
      />
      <VBtn
        medium
        color="create"
        :disabled="!serial.name"
        @click="createSerial"
      >
        Create
      </VBtn>
    </template>
  </VModal>
  <slot :open="open">
    <span
      class="link cursor-pointer"
      @click="open"
      >{{ label }}</span
    >
  </slot>
</template>

<script setup>
import { ref } from 'vue'
import { makeSerial } from '@/factory'
import { Serial } from '@/routes/endpoints'
import FormSerial from '@/components/Form/FormSerial/FormSerial.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineProps({
  label: {
    type: String,
    default: 'New'
  }
})

const emit = defineEmits(['create', 'close'])

const serial = ref(null)
const isModalVisible = ref(false)
const isSaving = ref(false)

function open() {
  serial.value = makeSerial()
  isModalVisible.value = true
}

function close() {
  isModalVisible.value = false
  emit('close')
}

function createSerial() {
  isSaving.value = true
  Serial.create({ serial: serial.value })
    .then(({ body }) => {
      emit('create', body)
      close()
      TW.workbench.alert.create('Serial was successfully created.', 'notice')
    })
    .catch(() => {})
    .finally(() => {
      isSaving.value = false
    })
}

defineExpose({
  open
})
</script>
