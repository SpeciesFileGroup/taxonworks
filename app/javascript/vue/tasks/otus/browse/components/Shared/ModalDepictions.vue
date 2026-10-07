<template>
  <div>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '500px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Depictions</h3>
      </template>
      <template #body>
        <div class="flex-wrap-row gap-small">
          <VSpinner
            v-if="isLoading"
            full-screen
          />
          <ImageViewer
            v-for="depiction in depictions"
            edit
            :depiction="depiction"
            :key="depiction.id"
          />
        </div>
      </template>
    </VModal>
    <VBtn
      v-if="count"
      class="horizontal-left-content gap-xsmall"
      variant="outline"
      title="Show depictions"
      @click="openModal"
    >
      <IconImage class="w-4 h-4" />
      <span>{{ count }}</span>
    </VBtn>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Depiction } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import IconImage from '@/components/Icon/IconImage.vue'

const props = defineProps({
  count: {
    type: Number,
    required: true
  },

  objectId: {
    type: Number,
    required: true
  },

  objectType: {
    type: String,
    required: true
  }
})

const isLoading = ref(false)
const isLoaded = ref(false)
const isModalVisible = ref(false)
const depictions = ref([])

async function loadDepictions() {
  if (isLoaded.value || isLoading.value) return

  isLoading.value = true

  try {
    const { body } = await Depiction.filter({
      depiction_object_id: [props.objectId],
      depiction_object_type: props.objectType
    })

    depictions.value = body
  } catch {
  } finally {
    isLoading.value = false
    isLoaded.value = true
  }
}

function openModal() {
  isModalVisible.value = true
  loadDepictions()
}
</script>
