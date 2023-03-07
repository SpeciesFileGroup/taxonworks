<template>
  <div class="radial-annotator">
    <modal
      v-if="isVisible"
      transparent
      @close="closeModal"
    >
      <template #header>
        <h3 class="flex-separate">
          <span>Radial label</span>
          <span class="separate-right"> {{ objectType }}</span>
        </h3>
      </template>
      <template #body>
        <div class="flex-separate">
          <div class="radial-annotator-menu">
            <div>
              <radial-menu
                :options="menuOptions"
                @on-click="createLabels"
              />
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
        name="label"
        x-small
      />
    </VBtn>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import RadialMenu from 'components/radials/RadialMenu.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import Modal from 'components/ui/Modal.vue'
import AjaxCall from 'helpers/ajaxCall'
import * as SLICES from './model/index.js'

const props = defineProps({
  disabled: {
    type: Boolean,
    default: false
  },

  ids: {
    type: Array,
    default: () => []
  },

  objectType: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['close'])
const menuOptions = computed(() => {
  const labels = SLICES[props.objectType]
  const slices = labels.map((item) => addSlice(item))

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

function addSlice({ label, link }) {
  return {
    label,
    name: link,
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

function createLabels({ name }) {
  const { link, param } = SLICES[props.objectType].find(
    (slice) => slice.link === name
  )

  AjaxCall('post', link, { [param]: props.ids }).then((_) => {
    TW.workbench.alert.create('Label was successfully created.', 'notice')
    closeModal()
  })
}
</script>

<script>
export default {
  name: 'RadialLabel'
}
</script>
