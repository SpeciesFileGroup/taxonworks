<template>
  <div>
    <textarea
      v-model="bibtexInput"
      rows=20
      cols=50
      placeholder="Paste BibTeX text here" />
  </div>
</template>
<script>
  export default {
    props: {
      value: {
        type: String,
        default: ''
      }
    },
    data: function () {
      return {
      bibtexInput: ''
      }
    },
    watch: {
      value(newVal) {
        this.bibtexInput = newVal;
      }
    }
  }
</script>
