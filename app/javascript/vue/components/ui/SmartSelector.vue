<template>
  <div ref="rootRef">
    <div class="separate-bottom horizontal-left-content gap-small">
      <div class="horizontal-left-content">
        <VSpinner
          v-if="isLoading"
          :show-legend="false"
          spinner-position="middle"
          :logo-size="{
            width: '24px',
            height: '24px'
          }"
        />
        <slot name="tabs-left" />
        <switch-components
          class="capitalize"
          v-model="view"
          ref="tabselectorRef"
          :options="options"
        />
      </div>
      <div class="horizontal-left-content gap-small">
        <default-pin
          v-if="pinSection"
          :section="pinSection"
          :type="pinType"
          @get-id="getObject"
        />
        <slot name="tabs-right" />
      </div>
    </div>
    <slot name="header" />
    <template v-if="!addTabs.includes(view)">
      <div class="margin-medium-bottom">
        <autocomplete
          ref="autocompleteRef"
          v-if="autocomplete && !otuPicker"
          :id="`smart-selector-${model}-autocomplete`"
          :input-id="inputId"
          :excluded-ids="filterIds"
          :placeholder="placeholder || 'Search...'"
          :url="autocompleteUrl ? autocompleteUrl : `/${model}/autocomplete`"
          param="term"
          :add-params="autocompleteParams"
          label="label_html"
          :clear-after="clear"
          display="label"
          :autofocus="autofocus"
          @key-event="changeTab"
          @get-item="getObject($event.id)"
        />
        <otu-picker
          v-if="otuPicker"
          :input-id="inputId"
          clear-after
          @get-item="sendObject"
        />
      </div>
      <slot name="body" />
      <template v-if="isImageModel">
        <div class="flex-wrap-row">
          <div
            v-for="image in lists[view]"
            :key="image.id"
            class="thumbnail-container margin-small cursor-pointer"
            @click="sendObject(image)"
          >
            <img
              :width="image.alternatives.thumb.width"
              :height="image.alternatives.thumb.height"
              :src="image.alternatives.thumb.image_file_url"
            />
          </div>
        </div>
      </template>
      <template v-else>
        <ul
          v-if="view"
          class="no_bullets"
          :style="listStyle"
          :class="{ 'flex-wrap-row': inline }"
        >
          <template
            v-for="item in lists[view]"
            :key="item.id"
          >
            <li
              v-if="filterItem(item)"
              class="list__item"
            >
              <template v-if="buttons">
                <button
                  type="button"
                  class="button normal-input tag_button"
                  :class="buttonClass"
                  v-html="item[label]"
                  @click.prevent="sendObject(item)"
                />
              </template>
              <template v-else>
                <label
                  class="cursor-pointer"
                  @mousedown="sendObject(item)"
                >
                  <input
                    :name="name"
                    @keyup="changeTab"
                    @keyup.enter="sendObject(item)"
                    @keyup.space="sendObject(item)"
                    :value="item.id"
                    :checked="selectedItem && item.id === selectedItem.id"
                    type="radio"
                  />
                  <span
                    :title="item[label]"
                    v-html="item[label]"
                  />
                </label>
              </template>
            </li>
          </template>
        </ul>
      </template>
    </template>
    <slot :name="view" />
    <slot />
    <slot name="footer" />
  </div>
</template>

<script setup>
import { ref, computed, watch, onUnmounted } from 'vue'
import { useOnResize } from '@/composables/index'
import { isMac } from '@/helpers/os'
import SwitchComponents from '@/components/ui/VSwitch'
import AjaxCall from '@/helpers/ajaxCall'
import Autocomplete from '@/components/ui/Autocomplete'
import OrderSmart from '@/helpers/smartSelector/orderSmartSelector'
import SelectFirst from '@/helpers/smartSelector/selectFirstSmartOption'
import DefaultPin from '@/components/ui/Button/ButtonPinned'
import OtuPicker from '@/components/otu/otu_picker/otu_picker'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  label: {
    type: String,
    default: 'object_tag'
  },

  inline: {
    type: Boolean,
    default: false
  },

  buttons: {
    type: Boolean,
    default: false
  },

  buttonClass: {
    type: String,
    default: 'button-data'
  },

  default: {
    type: String,
    default: undefined
  },

  otuPicker: {
    type: Boolean,
    default: false
  },

  autocompleteParams: {
    type: Object,
    default: undefined
  },

  autocomplete: {
    type: Boolean,
    default: true
  },

  autocompleteUrl: {
    type: String,
    default: undefined
  },

  inputId: {
    type: String,
    default: undefined
  },

  getUrl: {
    type: String,
    default: undefined
  },

  model: {
    type: String,
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

  selected: {
    type: [Array, String],
    default: undefined
  },

  clear: {
    type: Boolean,
    default: true
  },

  pinSection: {
    type: String,
    default: undefined
  },

  pinType: {
    type: String,
    default: undefined
  },

  ellipsis: {
    type: Boolean,
    default: true
  },

  addTabs: {
    type: Array,
    default: () => []
  },

  params: {
    type: Object,
    default: () => ({})
  },

  customList: {
    type: Object,
    default: () => ({})
  },

  name: {
    type: String,
    required: false,
    default: () => Math.random().toString(36).substr(2, 5)
  },

  filterIds: {
    type: [Number, Array],
    default: () => []
  },

  filterBy: {
    type: String,
    default: 'id'
  },

  filter: {
    type: Function,
    default: undefined
  },

  lockView: {
    type: Boolean,
    default: true
  },

  autofocus: {
    type: Boolean,
    default: false
  },

  extend: {
    type: Array,
    default: () => []
  },

  placeholder: {
    type: String,
    required: false
  }
})

const emit = defineEmits(['update:modelValue', 'onTabSelected', 'selected'])

const actionKey = isMac() ? 'Control' : 'Alt'

const autocompleteRef = ref(null)
const tabselectorRef = ref(null)
const rootRef = ref(null)

const lists = ref([])
const view = ref()
const options = ref([])
const lastSelected = ref()
const elementSize = useOnResize(rootRef)
const isLoading = ref(false)
const controller = ref(null)

const listStyle = computed(() => {
  return {
    'max-width': props.ellipsis ? `${elementSize.width}px` : 'auto'
  }
})

const selectedItem = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

const isImageModel = computed(() => props.model === 'images')

const getObject = (id) => {
  const params = {
    extend: props.extend
  }

  AjaxCall(
    'get',
    props.getUrl ? `${props.getUrl}${id}.json` : `/${props.model}/${id}.json`,
    { params }
  ).then((response) => {
    sendObject(response.body)
  })
}

const sendObject = (item) => {
  lastSelected.value = item
  selectedItem.value = item
  emit('selected', item)
}

const filterItem = (item) => {
  if (props.filter) {
    return props.filter(item)
  }

  return Array.isArray(props.filterIds)
    ? !props.filterIds.includes(item[props.filterBy])
    : props.filterIds !== item[props.filterBy]
}

const refresh = (forceUpdate = false) => {
  if (alreadyOnLists() && !forceUpdate) return
  const params = {
    klass: props.klass,
    target: props.target,
    extend: props.extend,
    ...props.params
  }

  autocompleteRef.value?.setText('')
  lists.value = []
  isLoading.value = true
  controller.value?.abort()
  controller.value = new AbortController()

  AjaxCall('get', `/${props.model}/select_options`, {
    params,
    signal: controller.value.signal
  })
    .then((response) => {
      lists.value = response.body
      addCustomElements()
      options.value = Object.keys(lists.value).concat(props.addTabs)
      options.value = OrderSmart(options.value)

      view.value = props.default
        ? props.default
        : SelectFirst(lists.value, options.value)
    })
    .catch(() => {
      options.value = []
      view.value = undefined
    })
    .finally(() => {
      isLoading.value = false
    })
}

const addToList = (listName, item) => {
  const index = lists.value[listName].findIndex(({ id }) => id === item.id)

  if (index > -1) {
    lists.value[listName][index] = item
  } else {
    lists.value[listName].push(item)
  }
}

const addCustomElements = () => {
  const keys = Object.keys(props.customList)

  if (keys.length) {
    keys.forEach((key) => {
      lists.value[key] = props.customList[key]

      if (!lists.value[key]) {
        options.value.push(key)
        options.value = OrderSmart(options.value)
      }
    })
  }

  if (!props.lockView) {
    view.value = SelectFirst(lists.value, options.value)
  }
}

const alreadyOnLists = () => {
  return (
    lastSelected.value &&
    []
      .concat(...Object.values(lists.value))
      .find((item) => item.id === lastSelected.value.id)
  )
}
const setFocus = () => {
  autocompleteRef.value?.setFocus()
}

const changeTab = (e) => {
  if (e.key !== actionKey) return
  const element = tabselectorRef.value.$el

  element.querySelector('input:checked')?.focus()
}

function setTab(tab) {
  if (options.value.includes(tab)) {
    view.value = tab
  }
}

watch(view, (newVal) => {
  emit('onTabSelected', newVal)
})

watch(
  () => props.customList,
  () => {
    addCustomElements()
  },
  { deep: true }
)

watch(
  () => props.model,
  () => {
    refresh(true)
  }
)

onUnmounted(() => {
  controller.value.abort()
  document.removeEventListener('smartselector:update', refresh)
})

refresh()
document.addEventListener('smartselector:update', refresh)

defineExpose({
  setFocus,
  setTab,
  addToList,
  refresh
})
</script>
<style scoped>
input:focus + span {
  font-weight: bold;
}
.list__item {
  padding: 2px 0;
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
}
</style>
