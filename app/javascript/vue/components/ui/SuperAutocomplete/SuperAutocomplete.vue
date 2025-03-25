<template>
  <div class="vue-autocomplete">
    <input
      type="text"
      ref="inputRef"
      :id="inputId"
      :placeholder="placeholder"
      :autofocus="autofocus"
      :disabled="disabled"
      v-model="inputValue"
      v-bind="inputAttributes"
      autocomplete="off"
      :class="[
        'vue-autocomplete-input normal-input',
        isLoading && 'ui-autocomplete-loading',
        !isLoading && 'vue-autocomplete-input-search',
        inputClass
      ]"
      @input="updateTimeout"
      @keydown.down="downKey"
      @keydown.up="upKey"
      @keydown.enter="enterKey"
      @keyup="sendKeyEvent"
    />
    <ul
      class="vue-autocomplete-list"
      v-show="isListVisible"
      v-if="inputValue && list.length"
    >
      <li
        v-for="(item, index) in limitList"
        class="vue-autocomplete-item"
        :class="{ active: currentIndex === index }"
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
        <VBtn
          v-if="item.expansion"
          color="primary"
          @click.stop="() => expansionRef.setItem(item)"
        >
          Expansion
        </VBtn>
      </li>
      <li v-if="list.length == 20">Results may be truncated</li>
    </ul>
    <ul
      v-if="inputValue && !isLoading && !list.length"
      class="vue-autocomplete-list vue-autocomplete-empty-list"
    >
      <li>--None--</li>
    </ul>
    <SuperAutocompleteExtension
      ref="expansionRef"
      :item="item"
    />
  </div>
</template>

<script setup>
import { computed, ref, onMounted, onBeforeUnmount, useTemplateRef } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import Qs from 'qs'
import SuperAutocompleteExtension from './SuperAutocompleteExpansion.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

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

const emit = defineEmits(['select', 'keyEvent', 'end'])
const isLoading = ref(false)
const isListVisible = ref(false)
const currentIndex = ref(-1)
const list = ref([])
const inputRef = useTemplateRef('inputRef')
const expansionRef = useTemplateRef('expansionRef')
const metadata = ref(null)
const level = ref(3)
let requestTimeout = null
let controller = null

const limitList = computed(() => {
  if (props.limit == 0) {
    return list.value
  }
  return props.limit ? list.value : list.value.slice(0, props.limit)
})

onMounted(() => {
  if (props.autofocus) {
    inputRef.value.focus()
  }

  AjaxCall('get', props.url).then(({ body }) => {
    metadata.value = body
  })
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

  if (props.autofocus) {
    inputRef.value.focus()
  }

  emit('select', item)
  isListVisible.value = false
}

function makeUrlRequest(params) {
  const url =
    props.url + '?' + props.param + '=' + encodeURIComponent(inputValue.value)

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

  const levels = Object.values(metadata.value.paths)
  const lvl = getLevelFromInput()
  list.value = []
  isLoading.value = true

  const maxLevel = lvl || level.value || levels.length
  const currentLevel = lvl || level.value || 1

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

function getLevelFromInput() {
  const regex = /!l(\d+)/
  const levelFromInput = inputValue.value.match(regex)

  return levelFromInput?.[1]
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
