<template>
  <span
    type="button"
    @click="loadPDF"
    class="circle-button pdf-button"/>
</template>

<script>
export default {
  props: {
    pdf: {
      type: Object,
      required: true
    }
  },

  methods: {
    loadPDF () {
      let details
      if (this.pdf.hasOwnProperty('file_url')) {
        details = {
          url: this.pdf.file_url
        }
      } else if (this.pdf.hasOwnProperty('document_file')) {
        details = {
          url: this.pdf.document_file
        }
      } else {
        details = {
          url: this.pdf.document.document_file,
          pageNumber: this.pdf.target_page
        }
      }
      document.dispatchEvent(new CustomEvent('pdfViewer:load', {
        detail: details
      }))
    }
  }
}
</script>
