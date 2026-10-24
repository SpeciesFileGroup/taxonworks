<template>
  <button
    type="button"
    @click="setItalics"
  >
    <i>Italics</i>
  </button>
</template>

<script setup>
const props = defineProps({
  textarea: {
    type: Object,
    default: null
  }
})

const text = defineModel({
  type: String,
  default: ''
})

function setItalics() {
  const value = text.value || ''
  const { selectionStart, selectionEnd } = props.textarea

  const textStart = value.slice(0, selectionStart)
  const textEnd = value.slice(selectionEnd)

  text.value =
    selectionStart === selectionEnd
      ? `${textStart}<i></i>${textEnd}`
      : `${textStart}<i>${value.slice(selectionStart, selectionEnd)}</i>${textEnd}`
}
</script>
