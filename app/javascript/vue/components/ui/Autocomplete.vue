<template>
  <div class="vue-autocomplete">
    <input
      v-model="state.type"
      :autofocus="autofocus"
      :class="{'ui-autocomplete-loading' : state.isLoading, 'vue-autocomplete-input-search' : !state.isLoading }"
      :disabled="disabled"
      :id="inputId"
      :placeholder="placeholder"
      :style="inputStyle"
      autocomplete="off"
      class="vue-autocomplete-input normal-input"
      ref="autocompleteElement"
      type="text"
      @input="updateRequestTimer(); emit('getInput', state.type)"
      @keydown.down="downKey"
      @keydown.up="upKey"
      @keydown.enter="enterKey"
      @keyup="sendKeyEvent"
    >
    <ul
      class="vue-autocomplete-list"
      v-show="state.showList"
      v-if="state.type && state.json.length"
    >
      <li
        v-for="(item, index) in renderList"
        class="vue-autocomplete-item"
        :class="activeClass(index)"
        @mouseover="itemActive(index)"
        @click.prevent="itemClicked(index)"
      >
        <span v-html="getItemLabel(item)" />
      </li>
      <li v-if="state.json.length == 20">
        Results may be truncated
      </li>
    </ul>
    <ul
      v-if="state.type && !state.requestTimeout && !state.json.length"
      class="vue-autocomplete-empty-list"
    >
      <li>--None--</li>
    </ul>
  </div>
</template>

<script setup>
import { reactive, onMounted, watch, ref, computed } from 'vue'
import AjaxCall from 'helpers/ajaxCall'

const props = defineProps({
  modelValue: {
    type: [String, Number]
  },

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
    default: undefined
  },

  headers: {
    type: Object,
    default: undefined
  },

  nested: {
    type: [String],
    default: ''
  },

  clearAfter: {
    type: Boolean,
    default: false
  },

  sendLabel: {
    type: String,
    default: ''
  },

  label: {
    type: [String, Array, Function],
    default: ''
  },

  display: {
    type: String,
    default: ''
  },

  delay: {
    type: [String, Number],
    default: '500'
  },

  arrayList: {
    type: Array,
    default: undefined
  },

  min: {
    type: [String, Number],
    default: 1
  },

  addParams: {
    type: Object,
    default: () => ({})
  },

  limit: {
    type: Number,
    default: 0
  },

  placeholder: {
    type: String,
    default: ''
  },

  param: {
    type: String,
    default: 'value'
  },

  inputStyle: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits([
  'update:modelValue',
  'getInput',
  'getItem',
  'found',
  'keyEvent',
  'select'
])

const state = reactive({
  isLoading: false,
  showList: false,
  requestTimeout: 0,
  type: props.sendLabel,
  json: [],
  current: -1,
  requestId: Math.random().toString(36).substr(2, 5)
})

const autocompleteElement = ref(null)

onMounted(() => {
  if (props.autofocus) {
    setFocus()
  }
})

watch(
  () => props.modelValue,
  newVal => {
    state.type = newVal
  }
)

watch(
  () => state.type,
  newVal => {
    if (state.type?.length < Number(props.min)) {
      state.json = []
    }
    emit('update:modelValue', newVal)
  }
)

watch(
  () => props.sendLabel,
  val => {
    state.type = val || ''
  }
)

const downKey = () => {
  if (state.showList && state.current < state.json.length) {
    state.current++
  }
}

const upKey = () => {
  if (state.showList && state.current > 0) {
    state.current--
  }
}

const enterKey = () => {
  if (state.showList && state.current > -1 && state.current < state.json.length) {
    itemClicked(state.current)
  }
}

const sendItem = item => {
  emit('update:modelValue', item)
  emit('getItem', item)
  emit('select', item)
}

const sendKeyEvent = e => {
  emit('keyEvent', e)
}

const cleanInput = () => {
  state.type = ''
}

const setText = value => {
  state.type = value
}

const renderList = computed(() => {
  return state.limit === 0
    ? state.json
    : state.json.slice(0, state.limit)
})

const getItemLabel = (item) => {
  const { label, nested } = props

  if (!label) {
    return item
  }

  if (Array.isArray(label)) {
    return nested.reduce((acc, current) => acc[current], item)
  } else if (typeof label === 'string') {
    return item[label]
  } else {
    return label(item)
  }
}

const itemClicked = index => {
  const item = state.json[index]

  if (props.display.length) {
    state.type = props.clearAfter ? '' : item[props.display]
  } else {
    state.type = props.clearAfter ? '' : getItemLabel(item)
  }

  if (props.autofocus) {
    setFocus()
  }

  sendItem(item)
  state.showList = false
}

const itemActive = index => {
  state.current = index
}

const updateRequestTimer = () => {
  clearTimeout(state.requestTimeout)
  state.current = -1
  state.requestTimeout = setTimeout(
    () => {
      requestList()
    },
    Number(props.delay)
  )
}

const requestList = async () => {
  if (state.type.length < Number(props.min)) return

  state.json = []
  state.isLoading = true

  const list = props.arrayList
    ? props.arrayList.filter(item => getItemLabel(item).toLowerCase().includes(state.type.toLowerCase()))
    : (await AjaxCall('get', props.url, {
        requestId: props.requestId,
        headers: props.headers,
        params: {
          [props.param]: state.type,
          ...props.addParams
        }
      })).body

  state.json = props.nested.split().reduce((acc, current) => acc[current], list) || list
  state.showList = state.json.length > 0
  state.isLoading = false
  state.requestTimeout = clearTimeout(state.requestTimeout)
}

const activeClass = index => ({
  active: state.current === index
})

const setFocus = () => {
  autocompleteElement.value.focus()
}

defineExpose({ setFocus, cleanInput, setText })
</script>
