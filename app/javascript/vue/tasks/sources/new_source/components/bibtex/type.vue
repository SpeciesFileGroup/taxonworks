<template>
  <div>
    <label v-help.section.BibTeX.type>Type</label>
    <br />
    <div class="horizontal-left-content">
      <select
        id="type"
        class="normal-input capitalize separate-right"
        v-model="source.bibtex_type"
        @change="() => (source.isUnsaved = true)"
      >
        <option
          v-for="item in TYPES"
          :key="item"
          :value="item"
        >
          {{ item }}
        </option>
      </select>
      <lock-component v-model="settings.lock.bibtex_type" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useSettingStore } from '../../store'
import LockComponent from '@/components/ui/VLock/index.vue'

const TYPES = ref([
  'article',
  'book',
  'booklet',
  'conference',
  'inbook',
  'incollection',
  'inproceedings',
  'manual',
  'mastersthesis',
  'misc',
  'phdthesis',
  'proceedings',
  'techreport',
  'unpublished'
])

const source = defineModel({
  type: Object,
  required: true
})

const settings = useSettingStore()
</script>
