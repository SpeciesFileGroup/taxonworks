<template>
  <div class="vue-autocomplete">
    <input
      type="text"
      ref="inputRef"
      :id="inputId"
      :style="inputStyle"
      :placeholder="placeholder"
      :autofocus="autofocus"
      :disabled="disabled"
      v-model="type"
      v-bind="inputAttributes"
      autocomplete="off"
      :class="[
        'vue-autocomplete-input normal-input',
        spinner && 'ui-autocomplete-loading',
        !spinner && 'vue-autocomplete-input-search',
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
      v-show="showList"
      v-if="type && json.length"
    >
      <li
        v-for="(item, index) in limitList(json)"
        class="vue-autocomplete-item"
        :class="{ active: currentIndex === index }"
        @mouseover="() => (currentIndex = index)"
        @click.prevent="() => selectItem(item)"
      >
        <span
          v-if="typeof label !== 'function'"
          v-html="getNested(item, label)"
        />
        <span
          v-else
          v-html="label(item)"
        />
      </li>
      <li v-if="json.length == 20">Results may be truncated</li>
    </ul>
    <ul
      v-if="inputValue && isLoading && !list.length"
      class="vue-autocomplete-empty-list"
    >
      <li>--None--</li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, useTemplateRef } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import Qs from 'qs'

const props = {
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

  params: {
    type: Object,
    default: () => ({})
  },

  inputAttributes: {
    type: Object,
    default: () => ({})
  },

  min: {
    type: Number,
    default: 2
  }
}

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
let requestTimeout = null
let controller = null

onMounted(() => {
  if (props.autofocus) {
    inputRef.value.focus()
  }
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

function limitList(list) {
  if (props.limit == 0) {
    return list
  }

  return props.limit ? list.value : list.value.slice(0, props.limit)
}

function selectItem(item) {
  inputValue.value = ''

  if (props.autofocus) {
    inputRef.value.focus()
  }

  emit('select', item)
  isListVisible.value = false
}

function makeUrlRequest() {
  let tempUrl =
    props.url + '?' + this.param + '=' + encodeURIComponent(inputValue.value)

  if (Object.keys(props.params).length) {
    tempUrl += `&${Qs.stringify(props.params, { arrayFormat: 'brackets' })}`
  }
  return tempUrl
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

function update() {
  if (inputValue.value.length < Number(props.min)) return

  list.value = []

  isLoading.value = true
  this.controller?.abort()
  this.controller = new AbortController()

  AjaxCall('get', makeUrlRequest(), {
    headers: props.headers,
    signal: controller.value.signal
  })
    .then(({ body }) => {
      list.value = props.exclude ? body.filter(props.exclude) : body

      isListVisible.value = list.value.length > 0
      this.$emit('end', this.showList)
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = true
    })
}

function setFocus() {
  inputRef.value.focus()
}

defineExpose({ cleanInput, setText, setFocus })
</script>
