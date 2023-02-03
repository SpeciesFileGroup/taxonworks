<template>
  <div ref="rootRef">
    <div class="separate-bottom horizontal-left-content">
      <switch-components
        class="full_width capitalize"
        v-model="view"
        ref="tabselectorRef"
        :options="options"
      />
      <default-pin
        v-if="pinSection"
        class="margin-small-left"
        :section="pinSection"
        :type="pinType"
        @get-id="getObject"
      />
      <slot name="tabs-right" />
    </div>
    <slot name="header" />
    <template v-if="!addTabs.includes(view)">
      <div class="margin-medium-bottom">
        <autocomplete
          ref="autocompleteRef"
          v-if="autocomplete"
          :id="`smart-selector-${model}-autocomplete`"
          :input-id="inputId"
          placeholder="Search..."
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
          :clear-after="true"
          @get-item="getObject($event.id)"
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
            >
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
                  >
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
import { useOnResize } from 'compositions/index'
import { isMac } from 'helpers/os'
import SwitchComponents from 'components/switch'
import AjaxCall from 'helpers/ajaxCall'
import Autocomplete from 'components/ui/Autocomplete'
import OrderSmart from 'helpers/smartSelector/orderSmartSelector'
import SelectFirst from 'helpers/smartSelector/selectFirstSmartOption'
import DefaultPin from 'components/getDefaultPin'
import OtuPicker from 'components/otu/otu_picker/otu_picker'

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
    default: () => (Math.random().toString(36).substr(2, 5))
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
  }
})

const emit = defineEmits([
  'update:modelValue',
  'onTabSelected',
  'selected'
])

const actionKey = isMac()
  ? 'Control'
  : 'Alt'

const autocompleteRef = ref(null)
const tabselectorRef = ref(null)
const rootRef = ref(null)

const lists = ref([])
const view = ref()
const options = ref([])
const lastSelected = ref()
const elementSize = useOnResize(rootRef)

const listStyle = computed(() => {
  return {
    'max-width': props.ellipsis ? `${elementSize.width}px` : 'auto'
  }
})

const selectedItem = computed({
  get () {
    return props.modelValue
  },
  set (value) {
    emit('update:modelValue', value)
  }
})

const isImageModel = computed(() => props.model === 'images')

const getObject = id => {
  const params = {
    extend: props.extend
  }

  AjaxCall('get', props.getUrl ? `${props.getUrl}${id}.json` : `/${props.model}/${id}.json`, { params }).then(response => {
    sendObject(response.body)
  })
}

const sendObject = item => {
  lastSelected.value = item
  selectedItem.value = item
  emit('selected', item)
}

const filterItem = item => {
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

  AjaxCall('get', `/${props.model}/select_options`, { params }).then(response => {
    lists.value = response.body
    addCustomElements()
    options.value = Object.keys(lists.value).concat(props.addTabs)
    options.value = OrderSmart(options.value)

    view.value = SelectFirst(lists.value, options.value)
  }).catch(() => {
    options.value = []
    lists.value = []
    view.value = undefined
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
    keys.forEach(key => {
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
  return lastSelected.value && [].concat(...Object.values(lists.value)).find(item => item.id === lastSelected.value.id)
}
const setFocus = () => {
  autocompleteRef.value.setFocus()
}

const changeTab = (e) => {
  if (e.key !== actionKey) return
  const element = tabselectorRef.value.$el

  element.querySelector('input:checked').focus()
}

watch(
  view,
  newVal => { emit('onTabSelected', newVal) }
)

watch(
  () => props.customList,
  () => { addCustomElements() },
  { deep: true }
)

watch(
  () => props.model,
  () => { refresh() }
)

onUnmounted(() => {
  document.removeEventListener('smartselector:update', refresh)
})

refresh()
document.addEventListener('smartselector:update', refresh)

defineExpose({
  setFocus,
  addToList
})
</script>
<style scoped>
  input:focus + span {
    font-weight: bold;
  }
  .list__item {
    padding:2px 0;
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
  }
</style>
