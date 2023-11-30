<template>
  <slot :action="downloadCSV">
    <VBtn
      class="circle-button"
      color="primary"
      :title="title"
      @click="downloadCSV"
    >
      <VIcon
        name="download"
        x-small
        :title="title"
      />
    </VBtn>
  </slot>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { Parser } from '@json2csv/plainjs'

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

function parseJSONToCSV() {
  try {
    const parser = new Parser(props.options)

    return parser.parse(props.list)
  } catch (err) {
    console.error(err)
  }
}

function downloadCSV() {
  const csvFile = parseJSONToCSV()
  const a = window.document.createElement('a')
  a.href = window.URL.createObjectURL(new Blob([csvFile], { type: 'text/csv' }))
  a.download = props.filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
}
</script>
