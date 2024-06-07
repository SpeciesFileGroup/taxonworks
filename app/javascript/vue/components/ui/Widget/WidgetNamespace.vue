<template>
  <VModal
    v-if="isModalVisible"
    @close="close"
  >
    <template #header>
      <h3>Namespace</h3>
    </template>
    <template #body>
      <VSpinner
        v-if="isSaving"
        legend="Saving..."
      />
      <FormNamespace
        class="margin-medium-bottom"
        v-model="namespace"
      />
      <VBtn
        medium
        color="create"
        :disabled="!namespace.short_name || !namespace.name"
        @click="createNamespace"
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
import { makeNamespace } from '@/factory'
import { Namespace } from '@/routes/endpoints'
import FormNamespace from '@/components/Form/FormNamespace/FormNamespace.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineProps({
  label: {
    type: String,
    default: 'New'
  }
})

const emit = defineEmits(['create'])

const namespace = ref(null)
const isModalVisible = ref(false)
const isSaving = ref(false)

function open() {
  namespace.value = makeNamespace()
  isModalVisible.value = true
}

function close() {
  isModalVisible.value = false
}

function createNamespace() {
  isSaving.value = true
  Namespace.create({ namespace: namespace.value })
    .then(({ body }) => {
      emit('create', body)
      isModalVisible.value = false
      TW.workbench.alert.create('Namespace was successfully created.', 'notice')
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
