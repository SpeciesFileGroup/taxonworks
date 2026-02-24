<template>
  <component :is="fieldset ? 'fieldset' : 'div'">
    <legend v-if="fieldset">Source</legend>
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
      >
        <template #tabs-right>
          <FormCitationClone
            v-if="!inlineClone"
            @clone="setCloneCitation"
          />
          <slot name="tabs-right" />
          <VLock
            v-if="lockButton"
            v-model="isLocked"
          />
        </template>
      </SmartSelector>
      <slot name="smart-selector-right" />
    </div>
    <div
      class="horizontal-left-content margin-medium-top gap-small"
      :class="!source && 'margin-medium-bottom'"
    >
      <VBtn
        v-if="submitButton"
        :color="submitButton.color"
        :disabled="!citation.source_id"
        medium
        @click="emit('submit', citation)"
      >
        {{ submitButton.label }}
      </VBtn>
      <VBtn
        v-if="newButton && citation.id"
        color="primary"
        medium
        @click="() => (citation = makeCitation())"
      >
        New
      </VBtn>
      <slot name="footer" />
    </div>
    <SmartSelectorItem
      :item="source"
      label="cached"
      @unset="setSource({})"
    />
    <div>
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
  </component>
</template>

<script setup>
import { Source } from '@/routes/endpoints'
import { computed, onBeforeMount, ref, watch } from 'vue'
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

  newButton: {
    type: Boolean,
    default: true
  },

  klass: {
    type: String,
    default: undefined
  },

  target: {
    type: String,
    default: undefined
  },

  fieldset: {
    type: Boolean,
    default: true
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
  'update',
  'update:modelValue',
  'update:absent'
])

const citation = defineModel({
  type: Object,
  default: () => makeCitation()
})

const isAbsent = computed({
  get: () => props.absent,
  set: (value) => emit('update:absent', value)
})

const isLocked = defineModel('lock', {
  type: Boolean,
  default: false
})

const sourceId = computed(() => props.modelValue.source_id)
const source = ref(undefined)

watch(sourceId, async (newId, oldId) => {
  if (newId) {
    if (newId !== oldId && newId !== source.value?.id) {
      source.value = (await Source.find(newId)).body
      citation.value.label = source.value.cached
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

  setValues({
    source_id: value.id,
    label: value.cached
  })

  emit('source', value)
}

function setValues(values) {
  Object.assign(citation.value, values)
  emit('update', citation.value)
}

function setPage(e) {
  const pages = e.target.value

  setValues({ pages })

  if (props.useSession) {
    sessionStorage.setItem(STORAGE.pages, e.target.value)
  }
}

function setIsOriginal(e) {
  const isOriginal = convertType(e.target.value)

  setValues({ is_original: isOriginal })

  if (props.useSession) {
    sessionStorage.setItem(STORAGE.isOriginal, isOriginal)
  }
}

function setIsAbsent(e) {
  if (props.useSession) {
    sessionStorage.setItem(STORAGE.isAbsent, e.target.value)
  }
}

function setCloneCitation(item) {
  setValues(item)

  if (isLocked.value) {
    sessionStorage.setItem(STORAGE.sourceId, item.source_id)
    sessionStorage.setItem(STORAGE.pages, item.pages)
    sessionStorage.setItem(STORAGE.isOriginal, item.is_original)
  }
}

onBeforeMount(() => {
  const lockStoreValue =
    props.useSession && convertType(sessionStorage.getItem(STORAGE.lock))

  if (lockStoreValue) {
    isLocked.value = lockStoreValue
  }

  if (
    props.lockButton &&
    lockStoreValue &&
    props.useSession &&
    !citation.value?.id
  ) {
    const cite = {
      source_id: convertType(sessionStorage.getItem(STORAGE.sourceId)),
      is_original: convertType(sessionStorage.getItem(STORAGE.isOriginal)),
      pages: convertType(sessionStorage.getItem(STORAGE.pages))
    }

    setValues(cite)

    isAbsent.value = convertType(sessionStorage.getItem(STORAGE.isAbsent))
  }
})
</script>
