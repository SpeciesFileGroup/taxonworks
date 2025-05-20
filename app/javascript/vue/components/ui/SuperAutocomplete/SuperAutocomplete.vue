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
      v-if="parsedInputValue.length && list.length"
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
      v-if="
        parsedInputValue.length > Number(props.min) &&
        !isLoading &&
        nothingFound
      "
      :class="[
        'vue-autocomplete-list vue-autocomplete-empty-list',
        isLoopOnLevels && 'super-autocomplete-countdown-list'
      ]"
    >
      <li
        v-if="isLoopOnLevels"
        class="flex-separate middle"
      >
        Nothing found, continuing on the next level...
        <VBtn
          color="primary"
          medium
          @click="
            () => {
              isLoopOnLevels = false
              clearTimeout(requestTimeout)
            }
          "
        >
          Cancel
        </VBtn>
      </li>
      <li v-else>--None--</li>
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
import VBtn from '@/components/ui/VBtn/index.vue'
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
const nothingFound = ref(false)
const isLoopOnLevels = ref(false)

let requestTimeout = null
let controller = null

const parsedInputValue = computed(() =>
  removeLevelShortcut(inputValue.value).trim()
)

const levels = computed(() =>
  metadata.value?.paths?.map((item) => ({
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
    encodeURIComponent(parsedInputValue.value)

  return Object.keys(params).length
    ? `${url}&${Qs.stringify(params, { arrayFormat: 'brackets' })}`
    : url
}

function updateTimeout() {
  currentIndex.value = -1
  isLoading.value = false
  isListVisible.value = false
  nothingFound.value = false
  list.value = []
  controller?.abort()

  if (requestTimeout) {
    clearTimeout(requestTimeout)
  }

  requestTimeout = setTimeout(update, props.delay)
}

async function update() {
  if (parsedInputValue.value.length < Number(props.min)) return

  const lvl = getLevelFromInput()
  const currentLevel = lvl || level.value || 1

  isLoopOnLevels.value = true

  getLevelRecords(currentLevel)
}

async function getLevelRecords(lvl) {
  level.value = lvl
  isLoading.value = true
  try {
    const response = await makeRequest(lvl)
    const data = response.body.response

    isLoading.value = false
    isListVisible.value = data.length > 0
    nothingFound.value = !data.length

    if (data.length) {
      list.value = props.exclude ? data.filter(props.exclude) : data

      emit('end', list.value)
    } else {
      if (lvl < levels.value.length) {
        requestTimeout = setTimeout(() => getLevelRecords(lvl + 1), 2000)
      } else {
        isLoopOnLevels.value = false
      }
    }
  } catch {}
}

function removeLevelShortcut(text) {
  return text.replace(/!\d+\s*/g, '')
}

function setLevel(lvl) {
  level.value = lvl
  list.value = []
  inputValue.value = inputValue.value.replace(/!\d+\s*/g, '')
  inputRef.value.focus()
  updateTimeout()
}

function getLevelFromInput() {
  const regex = /!(\d+)/
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

<style>
.super-autocomplete-countdown-list {
  position: relative;
  padding: 8px 0;
  margin-bottom: 12px;
  list-style: none;
}

.super-autocomplete-countdown-list::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  height: 2px;
  width: 0;
  background: #1f94d2;
  animation: fillLine 2s linear forwards;
}

@keyframes fillLine {
  from {
    width: 0;
  }
  to {
    width: 100%;
  }
}
</style>
