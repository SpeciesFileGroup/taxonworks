<template>
  <fieldset>
    <legend>Source</legend>
    <div class="horizontal-left-content align-start">
      <SmartSelector
        class="full_width"
        model="sources"
        :target="target"
        :klass="klass"
        pin-section="Sources"
        pin-type="Source"
        :shorten="100"
        label="cached"
        v-model="source"
        @selected="setSource"
      />
      <slot name="smart-selector-right" />
      <VLock
        v-if="lockButton"
        class="margin-small-left"
        v-model="isLocked"
      />
    </div>
    <SmartSelectorItem
      :item="source"
      label="cached"
      @unset="setSource({})"
    />
    <div class="margin-medium-bottom margin-medium-top">
      <ul class="context-menu no_bullets">
        <li>
          <input
            v-model="citation.pages"
            type="text"
            class="normal-input inline pages"
            placeholder="pages"
            @input="setPage"
          />
        </li>
        <li v-if="inlineClone">
          <FormCitationClone @clone="(item) => Object.assign(citation, item)" />
        </li>
        <li v-if="original">
          <label>
            <input
              v-model="citation.is_original"
              :value="citation.is_original"
              type="checkbox"
              @change="setIsOriginal"
            />
            Is original
          </label>
        </li>
        <li v-if="absentField">
          <label>
            <input
              v-model="isAbsent"
              :value="isAbsent"
              type="checkbox"
              @change="setIsAbsent"
            />
            Is absent
          </label>
        </li>
      </ul>
    </div>
    <div class="horizontal-left-content">
      <VBtn
        v-if="submitButton"
        class="margin-small-right"
        :color="submitButton.color"
        :disabled="!citation.source_id"
        medium
        @click="emit('submit', citation)"
      >
        {{ submitButton.label }}
      </VBtn>
      <FormCitationClone
        v-if="!inlineClone"
        @clone="(item) => Object.assign(citation, item)"
      />
      <slot name="footer" />
    </div>
  </fieldset>
</template>

<script setup>
import { Source } from '@/routes/endpoints'
import { computed, ref, watch, onMounted } from 'vue'
import { convertType } from '@/helpers/types'
import makeCitation from '@/factory/Citation'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VLock from '@/components/ui/VLock'
import FormCitationClone from './FormCitation/FormCitationClone.vue'

const STORAGE = {
  lock: 'radialObject::source::lock',
  sourceId: 'radialObject::source::id',
  pages: 'radialObject::source::pages',
  isOriginal: 'radialObject::source::isOriginal',
  isAbsent: 'radialObject::assertedDistribution::isAbsent'
}

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => makeCitation()
  },

  lockButton: {
    type: Boolean,
    default: false
  },

  absent: {
    type: Boolean,
    default: false
  },

  useSession: {
    type: Boolean,
    default: false
  },

  absentField: {
    type: Boolean,
    default: false
  },

  inlineClone: {
    type: Boolean,
    default: false
  },

  submitButton: {
    type: Object,
    default: undefined
  },

  klass: {
    type: String,
    default: undefined
  },

  target: {
    type: String,
    default: undefined
  },

  original: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits([
  'lock',
  'submit',
  'source',
  'update:modelValue',
  'update:absent'
])

const citation = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const isAbsent = computed({
  get: () => props.absent,
  set: (value) => emit('update:absent', value)
})

const isLocked = ref(false)

const sourceId = computed(() => props.modelValue.source_id)
const source = ref(undefined)

watch(sourceId, async (newId, oldId) => {
  if (newId) {
    if (newId !== oldId && newId !== source.value?.id) {
      source.value = (await Source.find(newId)).body
      citation.value._label = source.value.cached
    }
  } else {
    source.value = undefined
  }
})

watch(isAbsent, (newVal) => {
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.isAbsent, newVal)
  }
})

watch(isLocked, (newVal) => {
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.lock, newVal)
  }
  emit('lock', newVal)
})

function setSource(value) {
  source.value = value
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.sourceId, value.id)
  }
  citation.value.source_id = value.id
  citation.value._label = value.cached

  emit('source', value)
}

function setPage(e) {
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.pages, e.target.value)
  }
}

function setIsOriginal(e) {
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.isOriginal, e.target.value)
  }
}

function setIsAbsent(e) {
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.isAbsent, e.target.value)
  }
}

function init() {
  const lockStoreValue =
    props.useSession && convertType(sessionStorage.getItem(STORAGE.lock))

  if (lockStoreValue) {
    isLocked.value = lockStoreValue
  }

  if (props.lockButton && lockStoreValue && props.useSession) {
    citation.value.source_id = convertType(
      sessionStorage.getItem(STORAGE.sourceId)
    )
    citation.value.is_original = convertType(
      sessionStorage.getItem(STORAGE.isOriginal)
    )
    citation.value.pages = convertType(sessionStorage.getItem(STORAGE.pages))
    isAbsent.value = convertType(sessionStorage.getItem(STORAGE.isAbsent))
  }
}

onMounted(() => init())
</script>
