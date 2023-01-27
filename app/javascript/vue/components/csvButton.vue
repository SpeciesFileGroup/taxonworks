<template>
  <VBtn
    class="circle-button"
    color="primary"
    :title="title"
    :disabled="!csvFile"
    @click="downloadCSV"
  >
    <VIcon
      name="download"
      x-small
      :title="title"
    />
  </VBtn>
</template>

<script setup>
import { watch, ref } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { parse } from 'json2csv'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  options: {
    type: [Array, Object],
    default: () => []
  },

  filename: {
    type: String,
    default: 'list.csv'
  },

  title: {
    type: String,
    default: 'Download CSV'
  }
})

const csvFile = ref()

watch(
  () => props.list,
  (newVal) => {
    if (newVal.length) parseJSONToCSV()
    else csvFile.value = undefined
  },
  {
    deep: true,
    immediate: true
  }
)

watch(
  () => props.options,
  (newVal) => {
    if (props.list.length) parseJSONToCSV()
    else csvFile.value = undefined
  },
  {
    deep: true,
    immediate: true
  }
)

function parseJSONToCSV() {
  try {
    csvFile.value = parse(props.list, props.options)
  } catch (err) {
    console.error(err)
  }
}

function downloadCSV() {
  const a = window.document.createElement('a')
  a.href = window.URL.createObjectURL(
    new Blob([csvFile.value], { type: 'text/csv' })
  )
  a.download = props.filename

  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
}
</script>
