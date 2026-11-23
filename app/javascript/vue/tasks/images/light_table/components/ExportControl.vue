<template>
  <div class="horizontal-left-content middle">
    <select
      v-model="format"
      class="rounded-tr-none rounded-br-none"
    >
      <option
        v-for="option in FORMATS"
        :key="option.value"
        :value="option.value"
      >
        {{ option.label }}
      </option>
    </select>
    <VBtn
      class="rounded-tl-none rounded-bl-none"
      medium
      color="primary"
      :title="`Download the light table as ${selectedFormat.label}`"
      :disabled="disabled || isExporting"
      @click="exportImage"
    >
      <VIcon
        name="download"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { downloadBlob } from '@/helpers/files'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const FORMATS = [
  { label: 'PNG', value: 'png', extension: 'png' },
  { label: 'JPEG', value: 'jpeg', extension: 'jpg' },
  { label: 'SVG', value: 'svg', extension: 'svg' }
]

const props = defineProps({
  lightTable: {
    type: Object,
    default: null
  },

  fileName: {
    type: String,
    default: 'light_table'
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const format = ref(FORMATS[0].value)
const isExporting = ref(false)

const selectedFormat = computed(() =>
  FORMATS.find((o) => o.value === format.value)
)

function safeFileName(name) {
  const date = new Date().toISOString().slice(0, 10)

  return `${name.trim().replace(/[^\w.-]+/g, '_') || 'light_table'}_${date}.${selectedFormat.value.extension}`
}

async function exportImage() {
  isExporting.value = true

  try {
    const result = await props.lightTable.exportImage({ format: format.value })

    if (!result) return

    downloadBlob(result.blob, safeFileName(props.fileName))

    if (result.failed) {
      TW.workbench.alert.create(
        `${result.failed} image(s) could not be exported and were replaced by a placeholder.`,
        'notice'
      )
    }
  } catch {
    TW.workbench.alert.create('The light table could not be exported.', 'error')
  } finally {
    isExporting.value = false
  }
}
</script>
