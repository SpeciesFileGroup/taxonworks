<template>
  <div class="vue-autocomplete">
    <SuperAutocompleteLevelTracker
      v-if="metadata"
      :current-level="level"
      :levels="levels"
      @select="setLevel"
    />
    <input
      type="text"
      ref="inputRef"
      :id="inputId"
      :placeholder="isLoadingMetadata ? 'Loading...' : placeholder"
      :autofocus="autofocus"
      :disabled="isLoadingMetadata || disabled"
      v-model="inputValue"
      v-bind="inputAttributes"
      autocomplete="off"
      :class="[
        'vue-autocomplete-input normal-input',
        !isLoading && 'vue-autocomplete-input-search',
        inputClass
      ]"
      @input="updateTimeout"
      @keydown.down="downKey"
      @keydown.up="upKey"
      @keydown.enter="enterKey"
      @keyup="sendKeyEvent"
    />
    <template v-if="isLoading">
      <SuperAutocompleteSpinnerBank v-if="level === 3" />
      <SuperAutocompleteSpinner v-else />
    </template>
    <ul
      class="vue-autocomplete-list"
      v-show="isListVisible"
      v-if="inputValue && list.length"
    >
      <li
        v-for="(item, index) in limitList"
        class="vue-autocomplete-item horizontal-left-content middle"
        :class="{ active: currentIndex === index }"
        :style="{
          borderLeft: `4px solid ${levels[level - 1].color}`
        }"
        @mouseover="() => (currentIndex = index)"
        @click.prevent="() => selectItem(item)"
      >
        <span
          v-if="typeof label !== 'function'"
          v-html="item[label]"
        />
        <span
          v-else
          v-html="label(item)"
        />
      </li>
      <li v-if="list.length == 20">Results may be truncated</li>
    </ul>
    <ul
      v-if="inputValue && !isLoading && !list.length"
      class="vue-autocomplete-list vue-autocomplete-empty-list"
    >
      <li>--None--</li>
    </ul>
  </div>
</template>

<script setup>
import {
  computed,
  ref,
  onMounted,
  onBeforeUnmount,
  useTemplateRef,
  nextTick
} from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import Qs from 'qs'
import SuperAutocompleteSpinner from './SuperAutocompleteSpinner.vue'
import SuperAutocompleteLevelTracker from './SuperAutocompleteLevelTracker.vue'
import { randomHue } from '@/helpers'
import SuperAutocompleteSpinnerBank from './SuperAutocompleteSpinnerBank.vue'

const props = defineProps({
  inputId: {
    type: String,
    default: undefined
  },

  autofocus: {
    type: Boolean,
    default: false
  },

  disabled: {
    type: Boolean,
    default: false
  },

  url: {
    type: String,
    required: true
  },

  headers: {
    type: Object,
    default: () => ({})
  },

  label: {
    type: [String, Function],
    required: true
  },

  delay: {
    type: Number,
    default: 500
  },

  exclude: {
    type: Function,
    default: undefined
  },

  placeholder: {
    type: String,
    default: ''
  },

  param: {
    type: String,
    default: 'term'
  },

  params: {
    type: Object,
    default: () => ({})
  },

  inputAttributes: {
    type: Object,
    default: () => ({})
  },

  inputClass: {
    type: String,
    default: ''
  },

  min: {
    type: Number,
    default: 2
  }
})

const inputValue = defineModel({
  type: [String, Number],
  default: ''
})

const emit = defineEmits(['select', 'keyEvent', 'end', 'expand'])

const isLoading = ref(false)
const isListVisible = ref(false)
const currentIndex = ref(-1)
const list = ref([])
const inputRef = useTemplateRef('inputRef')
const metadata = ref(null)
const level = ref(1)
const isLoadingMetadata = ref(false)

let requestTimeout = null
let controller = null

const levels = computed(() =>
  metadata.value?.paths.map((item) => ({
    ...item,
    color: randomHue(item.level)
  }))
)

const limitList = computed(() => {
  if (props.limit == 0) {
    return list.value
  }
  return props.limit ? list.value : list.value.slice(0, props.limit)
})

onMounted(() => {
  isLoadingMetadata.value = true

  AjaxCall('get', props.url)
    .then(({ body }) => {
      metadata.value = body
      isLoadingMetadata.value = false

      if (props.autofocus) {
        nextTick(() => {
          inputRef.value.focus()
        })
      }
    })
    .catch(() => {})
})

onBeforeUnmount(() => controller?.abort())

function downKey() {
  if (isListVisible.value && currentIndex.value < list.value.length) {
    currentIndex.value++
  }
}

function upKey() {
  if (isListVisible.value && currentIndex.value > 0) {
    currentIndex.value--
  }
}

function enterKey() {
  if (
    isListVisible.value &&
    currentIndex.value > -1 &&
    currentIndex.value < list.value.length
  ) {
    selectItem(list.value[currentIndex.value])
  }
}

function sendKeyEvent(e) {
  emit('keyEvent', e)
}

function cleanInput() {
  inputValue.value = ''
}

function setText(value) {
  inputValue.value = value
}

function selectItem(item) {
  inputValue.value = ''

  if (item.expansion && !item.id) {
    emit('expand', item)
  } else {
    if (props.autofocus) {
      inputRef.value.focus()
    }

    emit('select', item)
    isListVisible.value = false
  }
}

function makeUrlRequest(params) {
  const url =
    props.url +
    '?' +
    props.param +
    '=' +
    encodeURIComponent(removeLevelShortcut(inputValue.value))

  return Object.keys(params).length
    ? `${url}&${Qs.stringify(params, { arrayFormat: 'brackets' })}`
    : url
}

function updateTimeout() {
  currentIndex.value = -1
  isLoading.value = false
  controller?.abort()

  if (requestTimeout) {
    clearTimeout(requestTimeout)
  }

  requestTimeout = setTimeout(update, props.delay)
}

async function update() {
  if (inputValue.value.length < Number(props.min)) return

  const lvl = getLevelFromInput()
  list.value = []
  isLoading.value = true

  if (lvl) {
    level.value = lvl
  }

  const maxLevel = level.value || levels.value.length
  const currentLevel = level.value || 1

  try {
    for (let i = currentLevel; i <= maxLevel; i++) {
      const response = await makeRequest(i)
      const data = response.body.response

      if (data.length) {
        list.value = props.exclude ? data.filter(props.exclude) : data
        isListVisible.value = list.value.length > 0

        emit('end', list.value)
        break
      }
    }
  } catch {}

  isLoading.value = false
}

function removeLevelShortcut(text) {
  return text.replace(/!l\d+\s*/g, '')
}

function setLevel(lvl) {
  level.value = lvl
  list.value = []
  inputValue.value = inputValue.value.replace(/!l\d+\s*/g, '')
  inputRef.value.focus()
  updateTimeout()
}

function getLevelFromInput() {
  const regex = /!l(\d+)/
  const levelFromInput = inputValue.value.match(regex)
  const lvl = levelFromInput?.[1]

  return lvl ? Number(lvl) : null
}

async function makeRequest(level) {
  const url = makeUrlRequest({
    ...props.params,
    level
  })

  controller?.abort()
  controller = new AbortController()

  const request = await AjaxCall('get', url, {
    headers: props.headers,
    signal: controller.signal
  })

  return request
}

function setFocus() {
  inputRef.value.focus()
}

defineExpose({ cleanInput, setText, setFocus })
</script>
