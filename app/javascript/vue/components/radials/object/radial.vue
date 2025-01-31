<template>
  <div>
    <div class="radial-annotator">
      <VModal
        v-if="isVisible"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <span class="flex-separate middle">
            <span v-html="title" />
            <b
              v-if="metadata"
              class="margin-large-left"
            >
              {{ metadata.object_type }}
            </b>
          </span>
        </template>
        <template #body>
          <div class="flex-separate">
            <spinner-component v-if="!metadata" />
            <div class="radial-annotator-menu">
              <div>
                <RadialMenu
                  v-if="metadata"
                  :options="menuOptions"
                  @click="selectComponent"
                />
              </div>
            </div>
            <div
              class="radial-annotator-template panel"
              v-if="currentAnnotator"
            >
              <h2 class="capitalize view-title">
                {{ currentAnnotator.replace('_', ' ') }}
              </h2>
              <component
                class="radial-annotator-container"
                :is="SLICE[currentAnnotator]"
                :type="currentAnnotator"
                :url="metadata.url"
                :metadata="metadata"
                :global-id="globalId"
                :object-id="metadata.object_id"
                :object-type="metadata.object_type"
                :radial-emit="handleEmitRadial"
                @update-count="setTotal"
                @close="closeModal"
              />
            </div>
          </div>
        </template>
      </VModal>
      <VBtn
        v-if="showBottom"
        :title="buttonTitle"
        color="radial"
        circle
        :disabled="disabled"
        @click="openRadialMenu()"
      >
        <VIcon
          :title="buttonTitle"
          name="radialObject"
          x-small
        />
      </VBtn>
      <div
        v-if="metadataCount && showCount"
        class="circle-count button-submit middle"
      >
        <span class="citation-count-text">{{ metadataCount }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import RadialMenu from '@/components/radials/RadialMenu.vue'
import VModal from '@/components/ui/Modal.vue'
import SpinnerComponent from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import makeRequest from '@/helpers/ajaxCall'
import Icons from './images/icons.js'
import { useShortcuts } from '@/components/radials/composables'
import { SLICE } from './constants/slices.js'
import { Tag } from '@/routes/endpoints'
import { ref, computed, onMounted } from 'vue'

const MIDDLE_RADIAL_BUTTON = 'circleButton'

defineOptions({
  name: 'QuickForms'
})

const props = defineProps({
  reload: {
    type: Boolean,
    default: false
  },

  globalId: {
    type: String,
    required: true
  },

  showBottom: {
    type: Boolean,
    default: true
  },

  buttonTitle: {
    type: String,
    default: 'Quick forms'
  },

  showCount: {
    type: Boolean,
    default: false
  },

  components: {
    type: Object,
    default: () => ({})
  },

  type: {
    type: String,
    default: 'graph'
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'update', 'create', 'delete', 'change'])
const currentAnnotator = ref(null)
const isVisible = ref(false)
const metadata = ref(null)
const title = ref('Quick forms')
const defaultTag = ref(null)
const { removeListener, setShortcutsEvent } = useShortcuts({
  metadata,
  currentAnnotator
})

const menuOptions = computed(() => {
  const { endpoints = {} } = metadata.value

  const slices = Object.entries(endpoints).map(([annotator, { total }]) => ({
    name: annotator,
    label: (annotator.charAt(0).toUpperCase() + annotator.slice(1)).replace(
      '_',
      ' '
    ),
    innerPosition: 1.7,
    svgAttributes: {
      class: currentAnnotator.value === annotator ? 'slice active' : 'slice'
    },
    slices: total
      ? [
          {
            label: total.toString(),
            size: 26,
            svgAttributes: {
              class: 'slice-total'
            }
          }
        ]
      : [],
    icon: Icons[annotator]
      ? {
          url: Icons[annotator],
          width: '20',
          height: '20'
        }
      : undefined
  }))

  return {
    width: 440,
    height: 440,
    sliceSize: 140,
    centerSize: 34,
    margin: 2,
    middleButton: middleButton.value,
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

const metadataCount = computed(() => {
  const values = Object.values(metadata.value?.endpoints || {})

  return values.reduce((acc, curr) => acc + curr.total, 0)
})

const middleButton = computed(() => ({
  name: MIDDLE_RADIAL_BUTTON,
  radius: 30,
  icon: {
    url: Icons.tags,
    width: '20',
    height: '20'
  },
  svgAttributes: {
    fill: getDefault() ? (defaultTag.value ? '#F44336' : '#9ccc65') : '#CACACA'
  }
}))

onMounted(() => {
  if (props.showCount) {
    loadMetadata()
  }
})

function getDefault() {
  const defaultTag = document.querySelector(
    '[data-pinboard-section="Keywords"] [data-insert="true"]'
  )

  return defaultTag?.getAttribute('data-pinboard-object-id')
}

function alreadyTagged() {
  const keyId = getDefault()
  if (!keyId) return

  const params = {
    global_id: props.globalId,
    keyword_id: keyId
  }

  Tag.exists(params).then(({ body }) => {
    defaultTag.value = body
  })
}

function selectComponent({ name }) {
  if (name === MIDDLE_RADIAL_BUTTON) {
    if (getDefault()) {
      defaultTag.value ? deleteTag() : createTag()
    }
  } else {
    currentAnnotator.value = name
  }
}

function closeModal() {
  isVisible.value = false
  eventClose()
  emit('close')
  removeListener()
}

async function openRadialMenu() {
  isVisible.value = true
  currentAnnotator.value = undefined
  await loadMetadata()
  alreadyTagged()
  setShortcutsEvent()
}

async function loadMetadata() {
  if (metadata.value && !props.reload) return

  const urlMetadata = `/${props.type}/${encodeURIComponent(
    props.globalId
  )}/metadata`

  return makeRequest('get', urlMetadata).then(({ body }) => {
    metadata.value = body
    title.value = body.object_tag
  })
}

function setTotal(total) {
  metadata.value.endpoints[currentAnnotator.value].total = total
}

function eventClose() {
  const event = new CustomEvent('radialObject:close', {
    detail: {
      metadata: metadata.value
    }
  })
  document.dispatchEvent(event)
}

function createTag() {
  const tag = {
    keyword_id: getDefault(),
    annotated_global_entity: props.globalId
  }

  Tag.create({ tag }).then((response) => {
    defaultTag.value = response.body
    TW.workbench.alert.create('Tag item was successfully created.', 'notice')
  })
}

function deleteTag() {
  Tag.destroy(defaultTag.value.id).then((_) => {
    defaultTag.value = undefined
    TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
  })
}

const handleEmitRadial = {
  add(item) {
    emit('create', { item, slice: currentAnnotator.value })
  },
  delete(item) {
    emit('delete', { item, slice: currentAnnotator.value })
  },
  update(item) {
    emit('update', { item, slice: currentAnnotator.value })
  },
  change(item) {
    emit('change', { item, metadata, slice: currentAnnotator.value })
  },
  count(total) {
    setTotal(total)
  }
}

defineExpose({
  openRadialMenu
})
</script>
