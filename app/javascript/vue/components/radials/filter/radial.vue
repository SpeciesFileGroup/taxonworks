<template>
  <div class="radial-annotator">
    <VModal
      v-if="isVisible"
      transparent
      @close="closeModal"
    >
      <template #header>
        <h3 class="flex-separate">
          <span>Radial filters</span>
          <span class="separate-right"> {{ objectType }}</span>
        </h3>
      </template>
      <template #body>
        <div class="horizontal-center-content">
          <RadialMenu
            :options="menuOptions"
            @on-click="saveParametersOnStorage"
          />
        </div>
      </template>
    </VModal>
    <VBtn
      class="circle-button"
      color="radial"
      :title="title"
      circle
      :disabled="disabled || (!Object.keys(filteredParameters).length && !ids)"
      @click="openRadialMenu()"
    >
      <VIcon
        :title="title"
        name="funnel"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { QUERY_PARAM } from './constants/queryParam'
import { ID_PARAM_FOR } from './constants/idParams'
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VModal from 'components/ui/Modal.vue'
import Qs from 'qs'
import * as FILTER_LINKS from './links'

const MAX_LINK_SIZE = 2048
const EXCLUDE_PARAMETERS = ['per', 'extend']

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  },

  objectType: {
    type: String,
    required: true
  },

  parameters: {
    type: Object,
    default: undefined
  },

  ids: {
    type: Array,
    default: undefined
  }
})

const emit = defineEmits(['close'])

const filteredParameters = computed(() => {
  const params = { ...props.parameters }

  EXCLUDE_PARAMETERS.forEach((param) => {
    delete params[param]
  })

  return filterEmptyParams(params)
})

const title = computed(() =>
  isOnlyIds.value
    ? 'Radial Filter (Send checked rows to filter)'
    : 'Radial Filter (Send full request to filter)'
)

const isOnlyIds = computed(() => Array.isArray(props.ids))
const filterLinks = computed(() => {
  const objLinks = FILTER_LINKS[props.objectType]

  return objLinks || []
})

const queryObject = computed(() => {
  const params = isOnlyIds.value
    ? { [ID_PARAM_FOR[props.objectType]]: props.ids }
    : { ...filteredParameters.value }

  return { [QUERY_PARAM[props.objectType]]: params }
})

const hasParameters = computed(
  () => !!Object.keys(filteredParameters.value).length || !!props.ids?.length
)

const menuOptions = computed(() => {
  const slices = filterLinks.value.map((item) => {
    const urlParameters = { ...queryObject.value, per: props.parameters?.per }

    const urlWithParameters =
      item.link +
      (hasParameters.value
        ? `?${Qs.stringify(urlParameters, { arrayFormat: 'brackets' })}`
        : '')

    return addSlice({
      ...item,
      link:
        urlWithParameters.length < MAX_LINK_SIZE ? urlWithParameters : item.link
    })
  })

  return {
    width: 500,
    height: 500,
    sliceSize: 190,
    centerSize: 34,
    margin: 2,
    innerPosition: 1.4,
    middleButton: {
      svgAttributes: {
        fill: 'transparent'
      }
    },
    svgAttributes: {
      class: 'svg-radial-menu'
    },
    svgSliceAttributes: {
      fontSize: 11,
      class: 'slice'
    },
    slices
  }
})

const isVisible = ref(false)

function addSlice({ label, link, name }) {
  return {
    label: splitLongWords(label),
    link,
    name,
    svgAttributes: {
      class: 'slice'
    }
  }
}

function closeModal() {
  isVisible.value = false
  emit('close')
}

function openRadialMenu() {
  isVisible.value = true
}

function saveParametersOnStorage() {
  if (hasParameters.value) {
    const params = { ...queryObject.value, per: props.parameters?.per }
    const state = JSON.stringify(params)
    const total = sessionStorage.getItem('totalFilterResult')
    const totalQueries =
      JSON.parse(sessionStorage.getItem('totalQueries')) || []

    totalQueries.push({
      objectType: props.objectType,
      params: queryObject.value,
      total
    })

    sessionStorage.setItem('totalQueries', JSON.stringify(totalQueries))
    sessionStorage.setItem('filterQuery', state)
  }
}

function filterEmptyParams(object) {
  const obj = { ...object }

  for (const key in obj) {
    const value = obj[key]

    if (
      value === '' ||
      value === undefined ||
      (Array.isArray(value) && !value.length)
    ) {
      delete obj[key]
    }
  }

  return obj
}

function splitLongWords(taskName) {
  const totalTasks = filterLinks.value.length
  const maxPerLine = totalTasks > 9 ? 10 : 16
  const arr = taskName.split(' ')
  const words = []

  arr.forEach((word) => {
    const wordLength = word.length
    const wordArr = []

    for (let i = 0; i < wordLength; i += maxPerLine) {
      wordArr.push(word.slice(i, maxPerLine + i))
    }

    words.push(wordArr.join('- '))
  })

  return words.join(' ')
}
</script>

<script>
export default {
  name: 'RadialFilter'
}
</script>
