<template>
  <div>
    <div class="field label-above">
      <label>Type</label>
      <select v-model="data.type">
        <option
          v-for="(label, type) in types"
          :key="type"
          :value="type"
        >
          {{ label }}
        </option>
      </select>
    </div>
    <div class="field label-above">
      <label>Title</label>
      <input
        class="w-full"
        type="text"
        v-model="data.title"
      />
    </div>
    <div class="field">
      <MarkdownEditor
        v-model="data.body"
        :configs="MARKDOWN_CONFIG"
      />
    </div>
    <div class="field label-above">
      <label>Start</label>
      <div class="flex-row gap-small">
        <input
          type="datetime-local"
          v-model="data.start"
        />
        <DateNow
          @datetime="
            (date) => (data.start = date.slice(0, date.lastIndexOf(':')))
          "
        />
      </div>
    </div>

    <div class="field label-above">
      <label>End</label>
      <div class="flex-row gap-small">
        <input
          type="datetime-local"
          v-model="data.end"
        />
        <DateNow
          @datetime="
            (date) => (data.end = date.slice(0, date.lastIndexOf(':')))
          "
        />
        <VBtn
          v-for="(label, key) in DEFAULT_BTN_VALUES"
          :key="key"
          color="primary"
          medium
          @click="setOffset(key)"
        >
          {{ label }}
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import DateNow from '@/components/ui/Date/DateNow.vue'
import MarkdownEditor from '@/components/markdown-editor.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { News } from '@/routes/endpoints'
import { ref } from 'vue'

const MARKDOWN_CONFIG = {
  status: false,
  spellChecker: false
}

const DEFAULT_BTN_VALUES = {
  '1h': '+1 hour',
  '1d': '+1 day',
  '1w': '+1 week',
  '1m': '+1 month'
}

const types = ref({})

const data = defineModel({
  type: Object,
  required: true
})

News.types().then(({ body }) => {
  const arrTypes = Object.values(body).flat()

  types.value = Object.fromEntries(
    arrTypes.map((item) => {
      const [_, namespace, type] = item.split('::')

      return [item, `${namespace}/${type}`]
    })
  )
})

function formatDate(date) {
  const pad = (n) => n.toString().padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(
    date.getDate()
  )}T${pad(date.getHours())}:${pad(date.getMinutes())}`
}

function addOffset(base, code) {
  const d = new Date(base)
  const num = parseInt(code)
  const unit = code.replace(num, '')

  switch (unit) {
    case 'h':
      d.setHours(d.getHours() + num)
      break
    case 'd':
      d.setDate(d.getDate() + num)
      break
    case 'w':
      d.setDate(d.getDate() + num * 7)
      break
    case 'm':
      d.setMonth(d.getMonth() + num)
      break
  }

  return d
}

function setOffset(code) {
  if (!data.value.start) {
    data.value.start = formatDate(new Date())
  }

  const base = new Date(data.value.end ?? data.value.start)

  data.value.end = formatDate(addOffset(base, code))
}
</script>
