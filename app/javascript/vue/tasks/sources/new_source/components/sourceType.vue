<template>
  <div class="horizontal-left-content field-options middle">
    <ul class="no_bullets context-menu">
      <li
        v-for="type in TYPES"
        :key="type.value"
      >
        <label
          class="flex-row gap-xsmall middle"
          v-help:path="`section.sourceType.${type.label}`"
        >
          <input
            v-model="store.source.type"
            type="radio"
            :value="type.value"
            :disabled="
              store.source.id &&
              (!type.available || !type.available.includes(store.source.type))
            "
            @change="(e) => updateType(e.target.value)"
          />
          {{ type.label }}
        </label>
      </li>
    </ul>
    <div class="margin-medium-left">
      <VLock v-model="settings.lock.type" />
    </div>
  </div>
</template>

<script setup>
import { useSourceStore, useSettingStore } from '../store'
import { SOURCE_BIBTEX, SOURCE_HUMAN, SOURCE_VERBATIM } from '@/constants'
import VLock from '@/components/ui/VLock/index.vue'

const TYPES = [
  {
    label: 'BibTeX',
    value: SOURCE_BIBTEX,
    available: [SOURCE_VERBATIM]
  },
  {
    label: 'Verbatim',
    value: SOURCE_VERBATIM
  },
  {
    label: 'Person',
    value: SOURCE_HUMAN
  }
]

const store = useSourceStore()
const settings = useSettingStore()

function updateType(newType) {
  store.reset({ type: newType })
}
</script>
