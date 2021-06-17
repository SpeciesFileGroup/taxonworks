<template>
  <button
    type="button"
    class="button button-circle btn-clipboard button-default"
    @click="copyToClipboard()"/>
</template>

<script>
export default {
  props: {
    text: {
      type: String,
      default: ''
    }
  },

  methods: {
    copyToClipboard () {
      const element = document.createElement('textarea')

      element.value = this.text
      document.body.appendChild(element)
      element.select()
      document.execCommand('copy')
      document.body.removeChild(element)
      TW.workbench.alert.create('Copied to clipboard', 'notice')
    }
  }
}
</script>
