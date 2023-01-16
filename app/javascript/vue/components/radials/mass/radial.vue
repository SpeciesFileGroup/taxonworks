<template>
  <div>
    <div
      class="radial-annotator">
      <VModal
        v-if="isModalVisible"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <h3 class="flex-separate">
            <span>Radial mass annotator</span>
            <span class="separate-right">
              {{ objectType }}
            </span>
          </h3>
        </template>
        <template #body>
          <div class="flex-separate">
            <VSpinner v-if="!Object.keys(annotatorTypes).length" />
            <div class="radial-annotator-menu">
              <div>
                <radial-menu
                  :options="menuOptions"
                  @onClick="selectComponent"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              :style="{ 'max-height': windowHeight(), 'min-height': windowHeight() }"
              v-if="currentAnnotator"
            >
              <h2 class="capitalize view-title">
                {{ currentAnnotator.replaceAll("_"," ") }}
              </h2>
              <component
                :is="ANNOTATORS[currentAnnotator]?.component"
                :object-type="objectType"
                :ids="ids"
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        title="Radial massive annoator"
        circle
        color="primary"
        medium
        :disabled="!ids.length"
        @click="isModalVisible = true"
      >
        A
      </VBtn>
    </div>
  </div>
</template>

<script setup>

import RadialMenu from 'components/radials/RadialMenu.vue'
import VModal from 'components/ui/Modal.vue'
import VSpinner from 'components/spinner.vue'
import Icons from 'components/radials/annotator/images/icons.js'
import VBtn from 'components/ui/VBtn/index.vue'
import { ANNOTATORS } from './constants/annotators.js'
import { Metadata, Tag } from 'routes/endpoints'
import { computed, ref, onBeforeMount } from 'vue'

const MIDDLE_RADIAL_BUTTON = 'circleButton'

const props = defineProps({
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

const isModalVisible = ref(false)
const currentAnnotator = ref()
const annotatorTypes = ref({})

const menuOptions = computed(() => {
  const annotators = annotatorTypes.value[props.objectType]?.filter(type => ANNOTATORS[type].component) || []

  const slices = annotators.map(type => ({
    name: type,
    label: ANNOTATORS[type].label,
    innerPosition: 1.7,
    svgAttributes: {
      class: currentAnnotator.value === type
        ? 'slice active'
        : 'slice'
    }
  }))

  return {
    width: 400,
    height: 400,
    sliceSize: 120,
    centerSize: 34,
    margin: 2,
    middleButton: middleButton(),
    svgAttributes: {
      class: 'svg-radial-menu'
    },
    svgSliceAttributes: {
      fontSize: 11
    },
    slices
  }
})

function middleButton () {
  return {
    name: MIDDLE_RADIAL_BUTTON,
    radius: 30,
    icon: {
      url: Icons.tags,
      width: '20',
      height: '20'
    },
    svgAttributes: {
      fontSize: 11,
      fill: getDefault() ? '#9ccc65' : '#CACACA',
      style: 'cursor: pointer'
    },
    backgroundHover: getDefault() ? '#81a553' : '#CACACA'
  }
}

function getDefault () {
  const defaultTag = document.querySelector('[data-pinboard-section="Keywords"] [data-insert="true"]')

  return defaultTag?.getAttribute('data-pinboard-object-id')
}

function selectComponent ({ name }) {
  if (name === MIDDLE_RADIAL_BUTTON) {
    if (getDefault()) {
      createTag()
    }
  } else {
    currentAnnotator.value = name
  }
}

function closeModal () {
  isModalVisible.value = false
  emit('close')
}

function windowHeight () {
  return ((window.innerHeight - 100) > 650 ? 650 : window.innerHeight - 100) + 'px !important'
}

function createTag () {
  Tag.createBatch({
    object_type: props.objectType,
    keyword_id: this.getDefault(),
    object_ids: props.ids
  }).then(() => {
    TW.workbench.alert.create('Tag item(s) were successfully created', 'notice')
  })
}

onBeforeMount(() => {
  Metadata.annotators().then(({ body }) => {
    annotatorTypes.value = body
  })
})
</script>

<script>
export default {
  name: 'RadialMassAnnotator'
}
</script>
