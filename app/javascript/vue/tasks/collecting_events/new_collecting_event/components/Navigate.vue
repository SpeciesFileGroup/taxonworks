<template>
  <div>
    <VBtn
      color="primary"
      medium
      @click="setModalView(true)"
      :disabled="!collectingEvent.id"
    >
      Navigate
    </VBtn>
    <VModal
      v-if="isModalVisible"
      @close="setModalView(false)"
      :container-style="{ width: '500px' }"
    >
      <template #header>
        <h3>Navigate</h3>
      </template>
      <template #body>
        <p>Current: <span v-html="collectingEvent.object_tag" /></p>
        <VSpinner v-if="isLoading" />
        <table class="full_width">
          <thead>
            <tr>
              <th>Previous by</th>
              <th>Next by</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="key in Object.keys(
                navigate.previous_by || navigate.next_by
              )"
              :key="key"
            >
              <td>
                <VBtn
                  color="primary"
                  medium
                  :disabled="!navigate.previous_by[key]"
                  @click="loadCE(navigate.previous_by[key])"
                >
                  {{ key.replaceAll('_', ' ') }}
                </VBtn>
              </td>
              <td>
                <VBtn
                  color="primary"
                  medium
                  :disabled="!navigate.next_by[key]"
                  @click="loadCE(navigate.next_by[key])"
                >
                  {{ key.replaceAll('_', ' ') }}
                </VBtn>
              </td>
            </tr>
          </tbody>
        </table>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner'
import VBtn from '@/components/ui/VBtn/index.vue'
import { CollectingEvent } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const props = defineProps({
  collectingEvent: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['select'])

const isLoading = ref(false)
const navigate = ref()
const isModalVisible = ref(false)

watch(
  () => props.collectingEvent.id,
  (newVal) => {
    if (newVal) {
      isLoading.value = true
      CollectingEvent.navigation(newVal)
        .then(({ body }) => {
          navigate.value = body
        })
        .finally(() => {
          isLoading.value = false
        })
    }
  }
)

function setModalView(value) {
  isModalVisible.value = value
}

function loadCE(id) {
  isModalVisible.value = false
  emit('select', { id })
}
</script>
