<template>
  <div>
    <textarea
      rows=20
      cols=50
      v-model="bibtexInput"
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
      // value(newVal) {
      //   this.bibtexInput = newVal;
      // },
      bibtexInput(newVal) {
        this.$emit('input', newVal)
      }
    }
  }
</script>
