<template>
  <label> Add OTU names, 1/line, or drop text file </label>
  <textarea
    ref="textareaRef"
    rows="20"
    v-model="names"
    placeholder="Search OTUs..."
  ></textarea>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
const names = defineModel({
  type: String,
  default: () => []
})

const textareaRef = ref(null)

onMounted(() => {
  textareaRef.value.addEventListener('dragover', (e) => {
    e.preventDefault()
  })
  textareaRef.value.addEventListener('drop', handleDrop)
})

function handleDrop(e) {
  e.preventDefault()
  const file = e.dataTransfer.files[0]

  if (file.type === 'text/plain') {
    const reader = new FileReader()

    reader.onload = function (event) {
      const contents = event.target.result
      names.value = contents
    }

    reader.readAsText(file)
  } else {
    alert('Please drag and drop text files only.')
  }
}

onBeforeUnmount(() => {
  textareaRef.value.removeEventListener('drop', handleDrop)
})
</script>
