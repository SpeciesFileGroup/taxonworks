<template>
  <div class="label-above">
    <label>Title</label>
    <button
      type="button"
      @click="setItalics"
    >
      <i>Italics</i>
    </button>
    <textarea
      id="title"
      ref="title"
      v-model="source.title"
      @change="() => (source.isUnsaved = true)"
    ></textarea>
  </div>
</template>

<script setup>
import { useTemplateRef } from 'vue'

const source = defineModel({
  type: Object,
  required: true
})

const titleRef = useTemplateRef('title')

function setItalics() {
  const { title } = source.value
  const { selectionStart, selectionEnd } = titleRef.value

  const titleStart = title.slice(0, selectionStart)
  const titleEnd = title.slice(selectionEnd)

  source.value.title =
    selectionStart === selectionEnd
      ? `${titleStart}<i></i>${titleEnd}`
      : `${titleStart}<i>${title.slice(
          selectionStart,
          selectionEnd
        )}</i>${titleEnd}`
}
</script>
