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
    <span
      v-if="showBottom"
      :title="buttonTitle"
      type="button"
      class="circle-button"
      :class="[buttonClass]"
      @click="displayRadialObject()"
    >
      Radial annotator
    </span>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { transformObjectToParams } from 'helpers/setParam'
import { copyObjectByArray } from 'helpers/objects.js'
import RadialMenu from 'components/radials/RadialMenu.vue'
import Modal from 'components/ui/Modal.vue'
import getFilterAttributes from './composition/getFilterAttributes'
import * as LINKER_LIST from './links/index.js'

const props = defineProps({
  objectType: {
    type: String,
    required: true
  },

  showBottom: {
    type: Boolean,
    default: true
  },

  buttonClass: {
    type: String,
    default: 'btn-radial-object'
  },

  buttonTitle: {
    type: String,
    default: 'Navigate radial'
  }
})

const emit = defineEmits(['close'])
const parameters = ref(getFilterAttributes())

const menuOptions = computed(() => {
  const links = LINKER_LIST[props.objectType]
  const sliceLinks = links.map(link => addSlice(link))

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
    slices: sliceLinks
  }
})

const isVisible = ref(false)

function addSlice ({ label, link, params }, attr = {}) {
  const objParameters = copyObjectByArray(parameters.value, params)
  const composedLink = link + '?' + transformObjectToParams(objParameters)

  return {
    label,
    name: link,
    link: composedLink,
    svgAttributes: {
      class: 'slice'
    },
    ...attr
  }
}

function closeModal () {
  isVisible.value = false
  emit('close')
}

function displayRadialObject () {
  isVisible.value = true
}

watch(
  isVisible,
  (newVal) => {
    if (newVal) {
      parameters.value = getFilterAttributes()
    }
  }
)

</script>

<script>
export default {
  name: 'RadialLinker'
}
</script>
