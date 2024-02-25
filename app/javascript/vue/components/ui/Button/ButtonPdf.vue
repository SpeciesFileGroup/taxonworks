<template>
  <VBtn
    color="primary"
    circle
    class="pdf-button"
    title="Open PDF"
    @click="loadPDF"
  />
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  pdf: {
    type: Object,
    required: true
  }
})

function loadPDF() {
  const detail = {
    url:
      props.pdf?.file_url ||
      props.pdf?.document_file ||
      props.pdf?.document.document_file,
    pageNumber: props?.pdf?.target_page
  }

  document.dispatchEvent(
    new CustomEvent('pdfViewer:load', {
      detail
    })
  )
}
</script>
