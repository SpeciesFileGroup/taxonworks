<template>
  <div class="radial-annotator">
    <modal
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
    </modal>
    <VBtn
      class="circle-button"
      color="primary"
      title="Radial filter"
      circle
      medium
      :disabled="disabled"
      @click="openRadialMenu()"
    >
      <VIcon
        title="Radial filter"
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
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import Modal from 'components/ui/Modal.vue'
import Qs from 'qs'
import * as FILTER_LINKS from './links'

const MAX_LINK_SIZE = 450
const EXCLUDE_PARAMETERS = [
  'per',
  'extend'
]

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
  }
})

const emit = defineEmits(['close'])

const filteredParameters = computed(() => {
  const params = { ...props.parameters }

  EXCLUDE_PARAMETERS.forEach(param => {
    delete params[param]
  })

  return filterEmptyParams(params)
})

const queryObject = computed(() => {
  const params = { ...filteredParameters.value }
  const currentQueryParam = QUERY_PARAM[props.objectType]
  const queryParams = Object.keys(params).filter(param => param.includes('_query'))

  queryParams.forEach(queryParam => {
    delete params[queryParam]
  })

  const queryParameters = Object.assign({}, ...queryParams.map(param => ({ [param]: filteredParameters.value[param] })))

  return currentQueryParam && Object.keys(params).length
    ? { [currentQueryParam]: params, ...queryParameters }
    : queryParameters
})

const hasParameters = computed(() => !!Object.keys(filteredParameters.value).length)

const menuOptions = computed(() => {
  const links = FILTER_LINKS[props.objectType]
  const slices = []

  links.forEach(item => {
    const currentQueryParam = getCurrentQueryParam(item.link)
    const params = removeParameter(currentQueryParam)
    const urlParameters = Qs.stringify(params)
    const urlWithParameters = item.link + (hasParameters.value ? `?${urlParameters}` : '')

    slices.push(
      addSlice(
        {
          ...item,
          name: currentQueryParam,
          link: urlWithParameters.length < MAX_LINK_SIZE
            ? urlWithParameters
            : item.link
        })
    )
  })

  return {
    width: 400,
    height: 400,
    sliceSize: 130,
    centerSize: 34,
    innerPosition: 1.7,
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

function addSlice ({ label, link, name }) {
  return {
    label,
    link,
    name,
    svgAttributes: {
      class: 'slice'
    }
  }
}

function closeModal () {
  isVisible.value = false
  emit('close')
}

function openRadialMenu () {
  isVisible.value = true
}

function saveParametersOnStorage ({ name }) {
  if (hasParameters.value) {
    const params = removeParameter(name)
    const state = JSON.stringify(params)

    sessionStorage.setItem('filterQuery', state)
  }
}

function getCurrentQueryParam (link) {
  const [targetObjectType] = Object.entries(FILTER_ROUTES).find(([key, value]) => value === link)
  const currentQueryParam = QUERY_PARAM[targetObjectType]

  return currentQueryParam
}

function removeParameter (param) {
  const params = { ...queryObject.value }

  delete params[param]

  return params
}

function filterEmptyParams (object) {
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
