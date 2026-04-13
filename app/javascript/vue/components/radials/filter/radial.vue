<template>
  <div class="radial-annotator">
    <VModal
      v-if="isVisible"
      transparent
      @close="closeModal"
    >
      <template #header>
        <h3 class="flex-separate middle">
          <span>Radial filters</span>
          <span class="margin-large-left"> {{ objectType }}</span>
        </h3>
      </template>
      <template #body>
        <div class="horizontal-center-content">
          <RadialMenu
            :options="menuOptions"
            @mousedown="saveParametersOnStorage"
          />
        </div>
      </template>
    </VModal>
    <VBtn
      class="circle-button"
      color="radial"
      :title="title"
      circle
      :disabled="isDisabled"
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
import {
  STORAGE_FILTER_QUERY_KEY,
  STORAGE_FILTER_QUERY_STATE_PARAMETER
} from '@/constants'
import { QUERY_PARAM } from './constants/queryParam'
import { ID_PARAM_FOR } from './constants/idParams'
import RadialMenu from '@/components/radials/RadialMenu.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import Qs from 'qs'
import { randomUUID } from '@/helpers'
import * as FILTER_LINKS from './links'

const MAX_LINK_SIZE = 2048
const EXCLUDE_PARAMETERS = ['page', 'per', 'extend', 'venn', 'venn_mode']

const uuid = randomUUID()

const props = defineProps({
  extendedSlices: {
    type: Array,
    default: () => []
  },

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

  title: {
    type: String,
    default: 'Radial Filter'
  },

  ids: {
    type: Array,
    default: undefined
  }
})

const emit = defineEmits(['close'])

const title = computed(() =>
  isOnlyIds.value
    ? `${props.title} (Send checked rows to filter)`
    : `${props.title} (Send full request to filter)`
)

const isOnlyIds = computed(() => Array.isArray(props.ids))

const filteredParameters = computed(() => {
  const params = { ...props.parameters }

  EXCLUDE_PARAMETERS.forEach((param) => {
    delete params[param]
  })

  return filterEmptyParams(params)
})

const isDisabled = computed(
  () =>
    props.disabled ||
    !filterLinks.value.length ||
    (!Object.keys(filteredParameters.value).length && !props.ids?.length)
)

const filterLinks = computed(() => {
  const slices = FILTER_LINKS[props.objectType] || []

  return [...slices, ...props.extendedSlices]
})

const objParameters = computed(() =>
  isOnlyIds.value
    ? { [ID_PARAM_FOR[props.objectType]]: props.ids }
    : { ...filteredParameters.value }
)

const queryObject = computed(() => {
  return { [QUERY_PARAM[props.objectType]]: objParameters.value }
})

const hasParameters = computed(
  () => !!Object.keys(filteredParameters.value).length || !!props.ids?.length
)

function getParametersBySlice(slice) {
  const params = slice.flattenQuery ? objParameters.value : queryObject.value

  return {
    ...params,
    ...slice.params,
    per: props.parameters?.per
  }
}

const menuOptions = computed(() => {
  const slices = filterLinks.value.map((item) => {
    const urlParameters = getParametersBySlice(item)

    const urlWithParameters =
      item.link +
      (hasParameters.value
        ? `?${Qs.stringify(urlParameters, { arrayFormat: 'brackets' })}`
        : '')

    return addSlice({
      ...item,
      link:
        urlWithParameters.length < MAX_LINK_SIZE
          ? urlWithParameters
          : item.link + `?${STORAGE_FILTER_QUERY_STATE_PARAMETER}=${uuid}`
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
      fontSize: 13,
      class: 'slice'
    },
    slices
  }
})

const isVisible = ref(false)

function addSlice({ label, link, name }) {
  return {
    label,
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

function saveParametersOnStorage(e) {
  const filterlink = filterLinks.value.find(
    (l) => l.label === e.segmentObject.slice.label
  )

  if (hasParameters.value) {
    const params = getParametersBySlice(filterlink)
    const total = sessionStorage.getItem('totalFilterResult')
    const totalQueries =
      JSON.parse(sessionStorage.getItem('totalQueries')) || []

    totalQueries.push({
      objectType: props.objectType,
      params: queryObject.value,
      total
    })

    sessionStorage.setItem('totalQueries', JSON.stringify(totalQueries))
    localStorage.setItem(
      STORAGE_FILTER_QUERY_KEY,
      JSON.stringify({ [uuid]: params })
    )
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
</script>

<script>
export default {
  name: 'RadialFilter'
}
</script>
