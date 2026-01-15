<template>
  <div class="d-inline-block">
    <VIcon
      v-if="lead.depictions.length"
      class="cursor-pointer"
      title="Show depictions"
      small
      height="12px"
      color="primary"
      name="image"
      @click="() => (isModalVisible = true)"
    />
    <VModal
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
      :container-style="{
        width: '1000px',
        maxHeight: '90vh',
        minHeight: '300px',
        overflow: 'auto'
      }"
    >
      <template #header>
        <h3>{{ lead.text }}</h3>
      </template>
      <template #body>
        <VSpinner v-if="isLoading" />
        <div class="flex-wrap-row">
          <ImageViewer
            v-for="item in depictions"
            :key="item.id"
            :depiction="item"
            thumb-size="medium"
          />
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VModal from '@/components/ui/Modal.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'

const props = defineProps({
  lead: {
    type: Object,
    required: true
  }
})

const depictions = ref([])
const isLoading = ref(false)
const isModalVisible = ref(false)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    const depictionIds = props.lead.depictions.map((d) => d.id)

    isLoading.value = true
    Depiction.where({
      depiction_id: depictionIds
    })
      .then(({ body }) => {
        depictions.value = body
      })
      .finally(() => {
        isLoading.value = false
      })
  }
})
</script>
