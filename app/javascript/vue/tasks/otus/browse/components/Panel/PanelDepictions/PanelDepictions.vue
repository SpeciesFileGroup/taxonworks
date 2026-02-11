<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <div
      class="flex-wrap-row"
      v-if="depictions.length"
    >
      <ImageViewer
        v-for="item in depictions"
        :key="item.id"
        :depiction="item"
        thumb-size="medium"
        edit
      />
    </div>
  </PanelLayout>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import PanelLayout from '../PanelLayout.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import isLoading from '@/tasks/digitize/store/getters/isLoading'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: status.LOADING
  },

  title: {
    type: String,
    default: 'Depictions'
  }
})

const depictions = ref([])

function loadDepictions(otuId) {
  isLoading.value = true

  try {
    const { body } = Depiction.where({
      otu_id: otuId,
      otu_scope: ['all'],
      per: 500
    })

    depictions.value = body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      loadDepictions(newVal)
    }
  },
  { immediate: true }
)
</script>
