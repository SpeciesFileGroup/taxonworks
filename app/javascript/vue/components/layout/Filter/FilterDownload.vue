<template>
  <div class="horizontal-left-content middle">
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
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { flatten } from '@json2csv/transforms'
import { decodeBasicEntities } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import csvButton from '@/components/csvButton.vue'
import DOMPurify from 'dompurify'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  csvOptions: {
    type: Object,
    default: () => undefined
  },

  onlyExtendDownload: {
    type: Boolean,
    default: false
  },

  extendDownload: {
    type: Array,
    default: () => []
  }
})

function stringFormatter(opts = {}) {
  const quote = typeof opts.quote === 'string' ? opts.quote : '"'
  const escapedQuote =
    typeof opts.escapedQuote === 'string'
      ? opts.escapedQuote
      : `${quote}${quote}`

  if (!quote || quote === escapedQuote) {
    return (value) => sanatizeValue(value)
  }

  return (value) => {
    if (value.includes(quote)) {
      value = value.replace(new RegExp(quote, 'g'), escapedQuote)
    }

    return `${quote}${sanatizeValue(value)}${quote}`
  }
}

function sanatizeValue(value) {
  const sanitizedValue = DOMPurify.sanitize(value, {
    USE_PROFILES: { html: false }
  })

  return decodeBasicEntities(sanitizedValue)
}

const csvDownload = computed(() => ({
  label: 'CSV',
  component: csvButton,
  bind: {
    list: props.list,
    options: {
      transforms: [flatten({ object: true, array: true, separator: '_' })],
      formatters: { string: stringFormatter() },
      ...props.csvOptions
    }
  }
}))

const DOWNLOAD_LIST = computed(() => {
  const list = props.extendDownload

  return props.onlyExtendDownload || list.some((item) => item.label === 'CSV')
    ? list
    : [csvDownload.value, ...list]
})

const selectedDownloadItem = computed(() =>
  DOWNLOAD_LIST.value.find(({ label }) => label === selectedDownloadLabel.value)
)

const selectedDownloadLabel = ref(DOWNLOAD_LIST.value[0]?.label)
</script>
