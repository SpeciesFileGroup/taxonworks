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
        <div class="flex-separate">
          <div class="radial-annotator-menu">
            <div>
              <radial-menu :options="menuOptions" />
            </div>
          </div>
        </div>
      </template>
    </modal>
    <VBtn
      class="circle-button"
      color="radial"
      title="Radial filter"
      circle
      :disabled="disabled"
      @click="openRadialMenu()"
    >
      <VIcon
        title="Radial filter"
        name="chain"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { copyObjectByArray } from 'helpers/objects.js'
import { ID_PARAM_FOR } from 'components/radials/filter/constants/idParams.js'
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import Modal from 'components/ui/Modal.vue'
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

const menuOptions = computed(() => {
  const slices = []

  filterLinks.value.forEach((item) => {
    const filteredParameters = filterEmptyParams(
      isOnlyIds.value ? getParametersForId() : getParametersForAll(item.params)
    )

    const link = item.link + '?' + qs.stringify(filteredParameters)

    if (Object.values(filteredParameters).some(Boolean)) {
      slices.push(addSlice({ ...item, link }))
    }
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
    middleButton: {
      // Middle button
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
    link,
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
