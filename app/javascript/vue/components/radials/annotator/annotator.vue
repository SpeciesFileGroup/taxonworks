<template>
  <div>
    <Teleport
      v-if="isVisible"
      :disabled="!teleport"
      to="body"
    >
      <div class="radial-annotator">
        <VModal
          transparent
          @close="closeModal()"
        >
          <template #header>
            <div class="horizontal-left-content middle gap-medium">
              <div
                :class="['inline model-tag', modelBg]"
                v-if="metadata"
              >
                {{ metadata.object_type }}
              </div>
              <span v-html="title" />
            </div>
          </template>
          <template #body>
            <div class="flex-separate">
              <VSpinner v-if="!isMetadataLoaded" />
              <div class="radial-annotator-menu">
                <div>
                  <radial-menu
                    v-if="isMetadataLoaded"
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
                  v-if="isMetadataLoaded"
                  class="radial-annotator-container"
                  :is="SLICE[currentAnnotator]"
                  :type="currentAnnotator"
                  :url="metadata.url"
                  :metadata="metadata"
                  :global-id="globalId"
                  :object-type="metadata.object_type"
                  :object-id="metadata.object_id"
                  :radial-emit="handleEmitRadial"
                  @update-count="setTotal"
                />
              </div>
            </div>
          </template>
        </VModal>
      </div>
    </Teleport>
    <VBtn
      v-if="showBottom"
      circle
      color="radial"
      :title="buttonTitle"
      :class="[pulse ? 'pulse-blue' : '']"
      :disabled="disabled"
      @contextmenu.prevent="loadContextMenu"
      @click="displayAnnotator()"
    >
      <VIcon
        :title="buttonTitle"
        name="radialAnnotator"
        x-small
      />
    </VBtn>
    <div
      v-if="metadataCount && showCount"
      class="circle-count button-submit middle"
    >
      <span class="citation-count-text">{{ metadataCount }}</span>
    </div>
    <ContextMenu
      :metadata="metadata"
      :global-id="globalId"
      v-model="isContextMenuVisible"
      v-if="isContextMenuVisible"
    />
  </div>
</template>

<script setup>
import { ref, computed, watch, onBeforeMount, onBeforeUnmount } from 'vue'
import { ajaxCall } from '@/helpers'
import { useShortcuts } from '@/components/radials/composables/useShortcuts'
import { Tag } from '@/routes/endpoints'
import { RadialAnnotatorEventEmitter } from '@/utils/index.js'
import { SLICE } from './constants/slices.js'
import RadialMenu from '@/components/radials/RadialMenu.vue'
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import Icons from './images/icons.js'
import ContextMenu from './components/contextMenu'
import {
  PERSON,
  PREPARATION_TYPE,
  REPOSITORY,
  SERIAL,
  ORGANIZATION,
  SOURCE,
  GEOGRAPHIC_AREA,
  NAMESPACE
} from '@/constants/modelTypes.js'

const MIDDLE_RADIAL_BUTTON = 'circleButton'

const DATA_COLOR = {
  shared: [
    PERSON,
    NAMESPACE,
    REPOSITORY,
    PREPARATION_TYPE,
    SERIAL,
    SOURCE,
    ORGANIZATION
  ],
  application: [GEOGRAPHIC_AREA]
}

defineOptions({
  name: 'RadialAnnotator'
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

  buttonClass: {
    type: String,
    default: 'btn-radial-annotator'
  },

  buttonTitle: {
    type: String,
    default: 'Radial annotator'
  },

  showCount: {
    type: Boolean,
    default: false
  },

  defaultView: {
    type: String,
    default: undefined
  },

  components: {
    type: Object,
    default: () => ({})
  },

  type: {
    type: String,
    default: 'annotations'
  },

  pulse: {
    type: Boolean,
    default: false
  },

  disabled: {
    type: Boolean,
    default: false
  },

  teleport: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'update', 'create', 'delete', 'change'])

const isMetadataLoaded = computed(() => !!metadata.value?.endpoints)
const isVisible = ref(false)
const isContextMenuVisible = ref(false)
const currentAnnotator = ref()
const title = ref('Radial annotator')
const metadata = ref(null)
const defaultTag = ref(null)
const modelBg = computed(() => {
  const objectType = metadata.value?.object_type

  if (!objectType) return

  const type = Object.keys(DATA_COLOR).find((key) => {
    return DATA_COLOR[key].includes(objectType)
  })

  return type || ''
})
const menuOptions = computed(() => {
  const endpoints = metadata.value.endpoints || {}

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
      fontSize: 11
    },
    slices
  }
})

const metadataCount = computed(() => {
  if (metadata.value) {
    let totalCounts = 0

    for (const key in metadata.value.endpoints) {
      const section = metadata.value.endpoints[key]
      if (typeof section === 'object') {
        totalCounts = totalCounts + Number(section.total)
      }
    }
    return totalCounts
  }
  return undefined
})

const isTagged = computed(() => !!defaultTag.value)

const middleButton = computed(() => ({
  name: MIDDLE_RADIAL_BUTTON,
  radius: 30,
  icon: {
    url: Icons.tags,
    width: '20',
    height: '20'
  },
  svgAttributes: {
    fontSize: 11,
    fill: getDefault() ? (isTagged.value ? '#F44336' : '#9ccc65') : '#CACACA',
    style: 'cursor: pointer'
  },
  backgroundHover: getDefault()
    ? isTagged.value
      ? '#CE3430'
      : '#81a553'
    : '#CACACA'
}))

const { removeListener, setShortcutsEvent } = useShortcuts({
  metadata,
  currentAnnotator
})

watch(isVisible, (newVal) => {
  if (newVal && isMetadataLoaded.value) {
    currentAnnotator.value = isComponentExist(props.defaultView)
  }
})

watch(isMetadataLoaded, () => {
  if (props.defaultView) {
    currentAnnotator.value = isComponentExist(props.defaultView)
  }
})

onBeforeMount(() => {
  if (props.showCount) {
    loadMetadata()
  }

  RadialAnnotatorEventEmitter.on('reset', resetAnnotator)
})

onBeforeUnmount(() => {
  RadialAnnotatorEventEmitter.removeListener('reset', resetAnnotator)
})

function isComponentExist(componentName) {
  return SLICE[componentName]
}

function loadContextMenu() {
  isContextMenuVisible.value = true
  loadMetadata()
}

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
      isTagged.value ? deleteTag() : createTag()
    }
  } else {
    currentAnnotator.value = name
  }
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
    emit('change', {
      item,
      metadata: metadata.value,
      slice: currentAnnotator.value
    })
  },
  count(total) {
    setTotal(total)
  }
}

function closeModal() {
  isVisible.value = false
  emit('close')
  removeListener()
}

async function displayAnnotator() {
  isVisible.value = true
  await loadMetadata()
  alreadyTagged()
  setShortcutsEvent()
}

async function loadMetadata() {
  if (
    isMetadataLoaded.value &&
    !props.reload &&
    metadata.value.annotation_target === props.globalId
  )
    return

  const metadataUrl = `/${props.type}/${encodeURIComponent(
    props.globalId
  )}/metadata`

  return ajaxCall('get', metadataUrl).then(({ body }) => {
    metadata.value = body
    title.value = body.object_tag
  })
}

function setTotal(total) {
  const sliceMetadata = metadata.value.endpoints[currentAnnotator.value]

  if (total !== sliceMetadata.total) {
    sliceMetadata.total = total
  }
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
  Tag.destroy(defaultTag.value.id).then(() => {
    defaultTag.value = undefined
    TW.workbench.alert.create('Tag item was successfully destroyed.', 'notice')
  })
}

function resetAnnotator() {
  metadata.value = undefined
}
</script>
<style lang="scss">
.dark {
  .svg-radial-menu {
    .slice {
      image {
        filter: invert(1);
      }
    }
  }
}

.svg-radial-menu {
  text-anchor: middle;

  g:hover {
    cursor: pointer;
    opacity: 0.9;
  }

  path.slice {
    fill: var(--bg-foreground);
  }

  .slice {
    tspan {
      fill: var(--text-color);
    }
  }

  path.active {
    fill: #8f8f8f;
  }

  path.slice-total {
    fill: #006ebf;
  }

  tspan.slice-total {
    fill: #ffffff;
  }
}

.radial-annotator {
  position: relative;
  width: initial;

  .modal-close {
    top: 30px;
    right: 20px;
  }

  .modal-mask {
    background-color: rgba(0, 0, 0, 0.7);
  }

  .modal-container {
    min-width: 1024px;
    width: 1200px;
    overflow-y: hidden;
  }

  .radial-annotator-template {
    background: var(--bg-foreground);
    padding: 1em;
    width: 100%;
    max-width: 100%;
    height: 70vh;
    overflow-y: auto;
  }

  .radial-annotator-container {
    display: flex;
    height: 100%;
    flex-direction: column;
    overflow-y: scroll;
    position: relative;
  }

  .radial-annotator-menu {
    width: 700px;
    height: 90vh;
  }

  .annotator-buttons-list {
    overflow-y: scroll;
  }

  .save-annotator-button {
    width: 100px;
  }

  .circle-count {
    bottom: -6px;
  }

  .model-tag {
    padding: 5px 8px;
    border-top-right-radius: 0.6rem;
    border-bottom-right-radius: 0.6rem;
    border: 1px solid var(--color-primary);
    border-left: 12px solid var(--color-primary);
    line-height: 1.2rem;
  }

  .shared {
    border: 1px solid var(--data-shared-bg);
    border-left: 12px solid var(--data-shared-bg);
  }

  .application {
    border: 1px solid var(--data-application-defined-bg);
    border-left: 12px solid var(--data-application-defined-bg);
  }
}

.tag_button {
  padding-left: 12px;
  padding-right: 8px;
  width: auto !important;
  min-width: auto !important;
  cursor: pointer;
  margin: 2px;
  border: none;
  border-top-left-radius: 15px;
  border-bottom-left-radius: 15px;
}
</style>
