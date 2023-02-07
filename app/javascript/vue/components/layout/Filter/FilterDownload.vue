<template>
  <select
    class="rounded-tr-none rounded-br-none"
    v-model="selectedDownloadLabel"
  >
    <option
      v-for="item in DOWNLOAD_LIST"
      :key="item.label"
      :value="item.label"
    >
      {{ item.label }}
    </option>
  </select>
  <component
    :is="selectedDownloadItem.component"
    :list="list"
    v-bind="selectedDownloadItem.bind"
    v-slot="{ action }"
  >
    <VBtn
      class="rounded-tl-none rounded-bl-none"
      medium
      color="primary"
      :title="selectedDownloadItem.label"
      :disabled="!list.length"
      @click="action"
    >
      <VIcon
        name="download"
        x-small
        :title="selectedDownloadItem.label"
      />
    </VBtn>
  </component>
</template>

<script setup>
import { ref, computed } from 'vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import csvButton from 'components/csvButton.vue'

const CSV_DOWNLOAD = {
  label: 'CSV',
  component: csvButton
}

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  parameters: {
    type: Object,
    default: () => ({})
  },

  extendDownload: {
    type: Array,
    default: () => []
  }
})

const DOWNLOAD_LIST = computed(() => [CSV_DOWNLOAD, ...props.extendDownload])

const selectedDownloadItem = computed(() =>
  DOWNLOAD_LIST.value.find(({ label }) => label === selectedDownloadLabel.value)
)

const selectedDownloadLabel = ref(CSV_DOWNLOAD.label)
</script>
