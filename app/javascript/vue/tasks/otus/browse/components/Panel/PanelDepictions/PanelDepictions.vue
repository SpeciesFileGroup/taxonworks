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
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Depictions'
  }
})

const depictions = ref([])
const isLoading = ref(false)

async function loadDepictions(otuId) {
  isLoading.value = true

  try {
    const { body } = await Depiction.where({
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
    const otuIds = newVal.map((o) => o.id)

    if (otuIds.length > 0) {
      loadDepictions(otuIds)
    }
  },
  { immediate: true }
)
</script>
