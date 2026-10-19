<template>
  <VModal
    :container-style="{
      width: '1000px',
      maxHeight: '90vh',
      minHeight: '300px',
      overflow: 'auto'
    }"
    @close="emit('close')"
  >
    <template #header>
      <h3>Depictions</h3>
    </template>
    <template #body>
      <div
        v-for="otu in otusWithDepictions"
        :key="otu.id"
        class="margin-medium-bottom"
      >
        <h4
          v-if="otus.length > 1"
          v-html="otu.object_tag"
        />
        <div class="flex-wrap-row gap-small">
          <ImageViewer
            v-for="depiction in depictionsByOtu[otu.id]"
            :key="depiction.id"
            :depiction="depiction"
            edit
          />
        </div>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import { computed } from 'vue'
import VModal from '@/components/ui/Modal.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'

const props = defineProps({
  otus: {
    type: Array,
    required: true
  },

  depictionsByOtu: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const otusWithDepictions = computed(() =>
  props.otus.filter((otu) => props.depictionsByOtu[otu.id])
)
</script>
