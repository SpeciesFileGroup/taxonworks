<template>
  <div class="radial-annotator">
    <modal
      v-if="isVisible"
      transparent
      @close="closeModal"
    >
      <template #header>
        <h3 class="flex-separate">
          <span>Radial linker</span>
          <span class="separate-right"> {{ objectType }}</span>
        </h3>
      </template>
      <template #body>
        <div class="horizontal-center-content">
          <radial-menu
            :options="menuOptions"
            @on-click="handleClick"
            @contextmenu="handleContextMenu"
          />
        </div>
      </template>
    </modal>
    <VBtn
      class="circle-button"
      color="radial"
      :title="title"
      circle
      :disabled="disabled || !filterLinks.length"
      @click="openRadialMenu()"
    >
      <VIcon
        :title="title"
        name="chain"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { copyObjectByArray, createAndSubmitForm } from '@/helpers'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams.js'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam.js'
import RadialMenu from '@/components/radials/RadialMenu.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import Modal from '@/components/ui/Modal.vue'
import getFilterAttributes from './composition/getFilterAttributes'
import qs from 'qs'
import * as LINKER_LIST from './links/index.js'

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
const objParameters = ref(getFilterAttributes())
const isOnlyIds = computed(() => Array.isArray(props.ids))
const filterLinks = computed(() => {
  const objLinks = LINKER_LIST[props.objectType]

  if (!objLinks) return []

  return isOnlyIds.value
    ? LINKER_LIST[props.objectType].ids
    : LINKER_LIST[props.objectType].all
})

const title = computed(() =>
  isOnlyIds.value
    ? 'Radial Linker (Send checked rows to task)'
    : 'Radial Linker (Send full request to task)'
)

const menuOptions = computed(() => {
  const slices = []

  filterLinks.value.forEach((item) => {
    const filteredParameters = filterEmptyParams(
      isOnlyIds.value ? getParametersForId() : getParametersForAll(item.params)
    )

    const parameters = item.queryParam
      ? { [QUERY_PARAM[props.objectType]]: filteredParameters }
      : filteredParameters

    const link =
      item.link + '?' + qs.stringify(parameters, { arrayFormat: 'brackets' })

    if (Object.values(filteredParameters).some(Boolean)) {
      if (item.post) {
        slices.push(addSlice({ label: item.label }))
      } else {
        slices.push(addSlice({ ...item, link }))
      }
    }
  })

  return {
    width: 500,
    height: 500,
    sliceSize: 190,
    centerSize: 34,
    margin: 2,
    innerPosition: 1.4,
    svgAttributes: {
      class: 'svg-radial-menu'
    },
    svgSliceAttributes: {
      fontSize: 13,
      class: 'slice'
    },
    middleButton: {
      radius: 28,
      name: 'middle',
      svgAttributes: {
        fill: 'transparent'
      }
    },
    slices
  }
})

const isVisible = ref(false)

function getParametersForAll(params) {
  const filteredParameters = params
    ? copyObjectByArray({ ...objParameters.value, ...props.parameters }, params)
    : { ...objParameters.value, ...props.parameters }

  return filteredParameters
}

function getParametersForId() {
  return {
    [ID_PARAM_FOR[props.objectType]]: props.ids
  }
}

function addSlice({ label, link }) {
  return {
    label,
    name: label,
    link,
    svgAttributes: {
      class: 'slice'
    }
  }
}

function closeModal() {
  isVisible.value = false
  sessionStorage.removeItem('linkerQuery')
  emit('close')
}

function openRadialMenu() {
  isVisible.value = true
}

function filterEmptyParams(object) {
  const obj = { ...object }

  for (const key in obj) {
    const value = obj[key]

    if (value === '' || (Array.isArray(value) && !value.length)) {
      delete obj[key]
    }
  }

  return obj
}

function handleClick({ name }) {
  const item = filterLinks.value.find(({ label }) => label === name)
  const filteredParameters = filterEmptyParams(
    isOnlyIds.value ? getParametersForId() : getParametersForAll()
  )

  if (item.post) {
    createAndSubmitForm({ action: item.link, data: filteredParameters })
  } else {
    sessionStorage.setItem('linkerQuery', JSON.stringify(filteredParameters))
  }
}

function handleContextMenu({ name }) {
  const item = filterLinks.value.find(({ label }) => label === name)
  const filteredParameters = filterEmptyParams(
    isOnlyIds.value ? getParametersForId() : getParametersForAll()
  )

  if (item.post) {
    createAndSubmitForm({
      action: item.link,
      data: filteredParameters,
      openTab: true
    })
  }
}

watch(isVisible, (newVal) => {
  if (newVal) {
    objParameters.value = getFilterAttributes()
  }
})
</script>

<script>
export default {
  name: 'RadialLinker'
}
</script>
