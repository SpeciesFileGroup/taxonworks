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
            v-model="sourceType"
            :value="type.value"
            :disabled="
              source.id &&
              (!type.available || !type.available.includes(source.type))
            "
            type="radio"
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
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { useStore } from 'vuex'
import { computed, watch } from 'vue'
import { SOURCE_BIBTEX, SOURCE_HUMAN, SOURCE_VERBATIM } from '@/constants'
import VLock from '@/components/ui/VLock/index.vue'
import makeNewSource from '../const/source.js'

const TYPES = [
  {
    label: 'BibTeX',
    value: SOURCE_BIBTEX,
    available: ['Source::Verbatim']
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

const store = useStore()

const source = computed({
  get: () => store.getters[GetterNames.GetSource],
  set: (value) => store.commit(MutationNames.SetSource, value)
})

const sourceType = computed({
  get: () => store.getters[GetterNames.GetType],
  set: (value) => store.commit(MutationNames.SetType, value)
})

const settings = computed({
  get: () => store.getters[GetterNames.GetSettings],
  set: (value) => store.commit(MutationNames.SetSettings, value)
})

watch(sourceType, (newVal) => {
  if (!source.value.id) {
    source.value = { ...makeNewSource(), type: newVal }
  }
})
</script>
