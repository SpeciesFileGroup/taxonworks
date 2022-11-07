<template>
  <div class="radial-annotator">
    <modal
      v-if="isVisible"
      :container-style="{
        backgroundColor: 'transparent',
        boxShadow: 'none'
      }"
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
import { computed, ref, watch } from 'vue'
import { transformObjectToParams } from 'helpers/setParam'
import { copyObjectByArray } from 'helpers/objects.js'
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import Modal from 'components/ui/Modal.vue'
import getFilterAttributes from './composition/getFilterAttributes'
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
  }
})

const emit = defineEmits(['close'])
const objParameters = ref(getFilterAttributes())

const menuOptions = computed(() => {
  const links = LINKER_LIST[props.objectType]
  const slices = []

  links.forEach(item => {
    const filteredParameters = copyObjectByArray({ ...objParameters.value, ...props.parameters }, item.params)
    const link = item.link + '?' + transformObjectToParams(filteredParameters)

    if (Object.values(filteredParameters).some(Boolean)) {
      slices.push(addSlice({ ...item, link }))
    }
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

function addSlice ({ label, link, params }) {
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

watch(
  isVisible,
  (newVal) => {
    if (newVal) {
      objParameters.value = getFilterAttributes()
    }
  }
)

</script>

<script>
export default {
  name: 'RadialLinker'
}
</script>
