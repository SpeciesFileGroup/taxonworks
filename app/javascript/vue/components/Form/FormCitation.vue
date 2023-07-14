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
            v-model="citationComputed.pages"
            type="text"
            class="normal-input inline pages"
            placeholder="pages"
            @input="setPage"
          />
        </li>
        <li v-if="!original">
          <label>
            <input
              v-model="citationComputed.is_original"
              :value="citationComputed.is_original"
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
        :disabled="!citationComputed.source_id"
        medium
        @click="submitCitation"
      >
        {{ submitButton.label }}
      </VBtn>
      <VBtn
        color="primary"
        medium
        @click="setLastCitation"
      >
        Clone my last citation
      </VBtn>
      <slot name="footer" />
    </div>
  </fieldset>
</template>

<script setup>
import { Source, Citation } from '@/routes/endpoints'
import { computed, ref, watch, onMounted } from 'vue'
import { convertType } from '@/helpers/types'
import makeCitation from '@/factory/Citation'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import SmartSelectorItem from '@/components/ui/SmartSelectorItem.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VLock from '@/components/ui/VLock'
import { getCurrentUserId } from '@/helpers/user'

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
    default: undefined
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
    default: false
  }
})

const emit = defineEmits([
  'lock',
  'submit',
  'source',
  'update:modelValue',
  'update:absent'
])

const citation = ref(props.modelValue || makeCitation())

const citationComputed = computed({
  get: () => citation.value,
  set: (value) => {
    citation.value = value
    emit('update:modelValue', value)
  }
})

const isAbsent = computed({
  get: () => props.absent,
  set: (value) => emit('update:absent', value)
})

const isLocked = ref(false)

const sourceId = computed(() => citation.value.source_id)
const source = ref(undefined)

watch(sourceId, async (newId, oldId) => {
  if (newId) {
    if (newId !== oldId && newId !== source.value?.id) {
      source.value = (await Source.find(newId)).body
      citationComputed.value._label = source.value.cached
    }
  } else {
    source.value = undefined
  }
})

watch(
  () => props.modelValue,
  (newVal) => {
    if (newVal) {
      citation.value = newVal
    } else {
      citation.value = makeCitation()
    }
  },
  { deep: true }
)

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
  citationComputed.value.source_id = value.id
  citationComputed.value._label = value.cached

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

function setLastCitation() {
  Citation.where({ recent: true, per: 1, user_id: getCurrentUserId() }).then(
    ({ body }) => {
      const [mostRecentCitation] = body

      if (mostRecentCitation) {
        Object.assign(citation.value, {
          pages: mostRecentCitation.pages,
          source_id: mostRecentCitation.source_id,
          is_original: mostRecentCitation.is_original
        })
      }
    }
  )
}

function submitCitation() {
  emit('submit', citationComputed.value)
  citation.value = { ...makeCitation() }
}

function init() {
  const lockStoreValue =
    props.useSession && convertType(sessionStorage.getItem(STORAGE.lock))

  if (lockStoreValue) {
    isLocked.value = lockStoreValue
  }

  if (props.lockButton && lockStoreValue && props.useSession) {
    citationComputed.value.source_id = convertType(
      sessionStorage.getItem(STORAGE.sourceId)
    )
    citationComputed.value.is_original = convertType(
      sessionStorage.getItem(STORAGE.isOriginal)
    )
    citationComputed.value.pages = convertType(
      sessionStorage.getItem(STORAGE.pages)
    )
    isAbsent.value = convertType(sessionStorage.getItem(STORAGE.isAbsent))
  }
}

onMounted(() => init())
</script>
