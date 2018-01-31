<template>
  <button
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
      loadPDF() {
        let event = new CustomEvent('pdfviewer:loadpdf', {
          detail: {
            url: this.pdf.document.document_file,
            pageNumber: this.pdf.target_page
          }
        })
        document.dispatchEvent(event);
      }
    }
  }
</script>

<style scoped>

</style>