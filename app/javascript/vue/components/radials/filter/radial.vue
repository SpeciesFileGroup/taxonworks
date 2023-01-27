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
        <div class="flex-separate">
          <div class="radial-annotator-menu">
            <div>
              <RadialMenu
                :options="menuOptions"
                @on-click="saveParametersOnStorage"
              />
            </div>
          </div>
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
import { FILTER_ROUTES } from 'routes/routes'
import { ID_PARAM_FOR } from './constants/idParams'
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VModal from 'components/ui/Modal.vue'
import Qs from 'qs'
import * as FILTER_LINKS from './links'

const MAX_LINK_SIZE = 450
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
  isOnlyIds.value ? 'Radial Filter (IDs)' : 'Radial Filter (Query params)'
)

const isOnlyIds = computed(() => Array.isArray(props.ids))
const filterLinks = computed(() => {
  const objLinks = FILTER_LINKS[props.objectType]

  if (!objLinks) return []

  return isOnlyIds.value ? objLinks.ids : objLinks.all
})
const queryObject = computed(() => {
  const params = { ...filteredParameters.value }
  const currentQueryParam = QUERY_PARAM[props.objectType]

  return { [currentQueryParam]: params }
})

const hasParameters = computed(
  () => !!Object.keys(filteredParameters.value).length || !!props.ids?.length
)

function getParametersForAll(link) {
  const currentQueryParam = getCurrentQueryParam(link)
  const params = unnestParameter(currentQueryParam)

  return params
}

function getParametersForId() {
  const params = {
    [ID_PARAM_FOR[props.objectType]]: props.ids
  }

  return params
}

const menuOptions = computed(() => {
  const slices = filterLinks.value.map((item) => {
    const urlParameters = isOnlyIds.value
      ? getParametersForId()
      : getParametersForAll(item.link)

    const urlWithParameters =
      item.link + (hasParameters.value ? `?${Qs.stringify(urlParameters)}` : '')

    return addSlice({
      ...item,
      name: getCurrentQueryParam(item.link),
      link:
        urlWithParameters.length < MAX_LINK_SIZE ? urlWithParameters : item.link
    })
  })

  return {
    width: 400,
    height: 400,
    sliceSize: 130,
    centerSize: 34,
    margin: 2,
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

function saveParametersOnStorage({ name }) {
  if (hasParameters.value) {
    const params = isOnlyIds.value
      ? getParametersForId()
      : unnestParameter(name)
    const state = JSON.stringify(params)

    sessionStorage.setItem('filterQuery', state)
  }
}

function getCurrentQueryParam(link) {
  const [targetObjectType] = Object.entries(FILTER_ROUTES).find(
    ([key, value]) => value === link
  )
  const currentQueryParam = QUERY_PARAM[targetObjectType]

  return currentQueryParam
}

function unnestParameter(param) {
  const params = { ...queryObject.value }
  return params

  delete params[param]

  return {
    ...params,
    ...queryObject.value[param]
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
