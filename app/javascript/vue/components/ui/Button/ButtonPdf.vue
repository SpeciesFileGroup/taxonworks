<template>
  <VBtn
    v-if="pdf.document_file_content_type === PDF_CONTENT_TYPE"
    color="primary"
    circle
    class="pdf-button"
    title="Open PDF"
    @click="loadPDF"
  />
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

const PDF_CONTENT_TYPE = 'application/pdf'

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
