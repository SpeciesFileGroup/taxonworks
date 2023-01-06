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
import Qs from 'qs'
import { QUERY_PARAM } from './constants/queryParam'
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import Modal from 'components/ui/Modal.vue'
import * as FILTER_LINKS from './links'

const MAX_LINK_SIZE = 450

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

const filteredParameters = computed(() => filterEmptyParams({ ...props.parameters, per: undefined }))
const queryObject = computed(() => ({ [QUERY_PARAM[props.objectType]]: filteredParameters.value }))
const hasParameters = computed(() => !!Object.keys(filteredParameters.value).length)

const menuOptions = computed(() => {
  const links = FILTER_LINKS[props.objectType]
  const urlParameters = Qs.stringify(queryObject.value, { arrayFormat: 'brackets' })
  const slices = []

  console.log(hasParameters.value)
  console.log(filteredParameters.value)

  links.forEach(item => {
    const urlWithParameters = item.link + (hasParameters.value ? `?${urlParameters}` : '')

    slices.push(
      addSlice(
        {
          ...item,
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

function addSlice ({ label, link }) {
  return {
    label,
    link,
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

function saveParametersOnStorage (e) {
  if (hasParameters.value) {
    const state = JSON.stringify(queryObject.value)

    sessionStorage.setItem('filterQuery', state)
  }
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
