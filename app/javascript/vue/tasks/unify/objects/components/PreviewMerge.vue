<template>
  <div>
    <VBtn
      color="primary"
      :disabled="!keep?.global_id || !remove?.global_id || disabled"
      @click="openModal"
    >
      Preview
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ minWidth: '800px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Preview</h3>
      </template>
      <template #body>
        <VSpinner v-if="isLoading" />
        <TableResponse
          class="margin-medium-bottom"
          :response="previewResponse"
        />
        <ButtonMerge
          :keep-global-id="keep?.global_id"
          :remove-global-id="remove?.global_id"
          :remove="remove"
          :only="only"
          :disabled="!previewResponse?.result?.unified"
          @merge="
            () => {
              onMerge()
              isModalVisible = false
            }
          "
        />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Unify } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import TableResponse from './TableResponse.vue'
import ButtonMerge from './ButtonMerge.vue'

const props = defineProps({
  keep: {
    type: Object,
    default: undefined
  },

  remove: {
    type: Object,
    default: undefined
  },

  only: {
    type: Array,
    default: () => []
  },

  onMerge: {
    type: Function,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const previewResponse = defineModel('response', {
  type: Object,
  default: () => ({})
})

const isModalVisible = ref(false)

const isLoading = ref(false)

function openModal() {
  isModalVisible.value = true
  isLoading.value = true
  previewResponse.value = {}

  const payload = {
    remove_global_id: props.remove.global_id,
    keep_global_id: props.keep.global_id,
    preview: true
  }

  if (props.only.length !== Object.keys(props.remove._metadata).length) {
    Object.assign(payload, { only: props.only })
  }

  Unify.merge(payload)
    .then(({ body }) => {
      previewResponse.value = body

      if (body.result.message) {
        TW.workbench.alert.create(body.result.message, 'error')
        isModalVisible.value = false
      }
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}
</script>
