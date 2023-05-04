<template>
  <div>
    <div class="radial-annotator">
      <VModal
        v-if="isModalVisible"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <h3>Radial Loan</h3>
        </template>
        <template #body>
          <div class="flex-separate">
            <div class="radial-annotator-menu">
              <div>
                <radial-menu
                  :options="menuOptions"
                  @on-click="selectSlice"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              v-if="currentSlice"
            >
              <h2 class="view-title">
                {{ currentSlice }}
              </h2>
              <component
                :is="SLICES[currentSlice]"
                :ids="ids"
                :parameters="params"
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        title="Radial Loan"
        circle
        color="radial"
        :disabled="!ids.length && !Object.keys(params).length"
        @click="isModalVisible = true"
      >
        L
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import RadialMenu from 'components/radials/RadialMenu.vue'
import VModal from 'components/ui/Modal.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import AddSlice from './components/AddSlice.vue'
import ReturnSlice from './components/ReturnSlice.vue'
import ReturnAndAddSlice from './components/ReturnAndAddSlice.vue'
import { computed, ref } from 'vue'
import { removeEmptyProperties } from 'helpers/objects.js'

const EXCLUDE_PARAMETERS = ['per']
const SLICES = {
  Add: AddSlice,
  Return: ReturnSlice,
  'Return and Add': ReturnAndAddSlice
}

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  parameters: {
    type: Object,
    default: () => ({})
  }
})

const params = computed(() => {
  const parameters = removeEmptyProperties({
    ...props.parameters,
    collection_object_id: props.ids
  })

  EXCLUDE_PARAMETERS.forEach((param) => {
    delete parameters[param]
  })

  return removeEmptyProperties(parameters)
})

const emit = defineEmits(['close'])

const isModalVisible = ref(false)
const currentSlice = ref()

const menuOptions = computed(() => {
  const sliceName = Object.keys(SLICES)

  const slices = sliceName.map((type) => ({
    name: type,
    label: type,
    innerPosition: 1.7,
    svgAttributes: {
      class: currentSlice.value === type ? 'slice active' : 'slice'
    }
  }))

  return {
    width: 400,
    height: 400,
    sliceSize: 120,
    centerSize: 34,
    margin: 2,
    svgAttributes: {
      class: 'svg-radial-menu'
    },
    svgSliceAttributes: {
      fontSize: 11
    },
    slices
  }
})

function selectSlice({ name }) {
  currentSlice.value = name
}

function closeModal() {
  isModalVisible.value = false
  emit('close')
}
</script>

<script>
export default {
  name: 'RadialLoan'
}
</script>
