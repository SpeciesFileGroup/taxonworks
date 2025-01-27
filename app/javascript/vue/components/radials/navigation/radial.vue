<template>
  <div v-if="!deleted">
    <div class="radial-annotator">
      <VModal
        v-if="isRadialOpen"
        transparent
        @close="closeModal()"
      >
        <template #header>
          <span class="flex-separate middle">
            <span v-html="title" />
            <b
              v-if="metadata"
              class="separate-right"
              v-text="metadata.type"
            />
          </span>
        </template>
        <template #body>
          <div class="horizontal-center-content">
            <spinner v-if="isLoading" />
            <RadialMenu
              v-if="metadata"
              ref="radialElement"
              :options="menuOptions"
              @click="selectedRadialOption"
            />
            <DestroyConfirmation
              v-if="showDestroyModal"
              @close="showDestroyModal = false"
              @confirm="destroyObject"
            />
          </div>
        </template>
      </VModal>
      <AllTasks
        v-if="isAlltaskSelected"
        @close="isAlltaskSelected = false"
        :metadata="metadata"
      />

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
          name="radialNavigator"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import RadialMenu from '@/components/radials/RadialMenu.vue'
import Spinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import Icons from './images/icons.js'
import DestroyConfirmation from './components/DestroyConfirmation'
import AllTasks from './components/allTasks.vue'
import ajaxCall from '@/helpers/ajaxCall'
import { PinboardItem } from '@/routes/endpoints'
import { computed, ref, watch } from 'vue'
import VModal from '@/components/ui/Modal.vue'

const DEFAULT_OPTIONS = {
  New: 'New',
  Edit: 'Edit',
  Destroy: 'Destroy',
  Recent: 'Recent',
  Show: 'Show',
  Related: 'Related',
  Unify: 'Unify'
}

const CUSTOM_OPTIONS = {
  AllTasks: 'allTasks',
  CircleButton: 'circleButton'
}

const props = defineProps({
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
    default: 'Radial navigator'
  },

  maxTaskInPie: {
    type: Number,
    default: 4
  },

  components: {
    type: Object,
    default: () => ({})
  },

  exclude: {
    type: [String, Array],
    default: () => []
  },

  disabled: {
    type: Boolean,
    default: false
  },

  redirect: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['close', 'delete'])

const defaultTasks = computed(() => ({
  graph_object: {
    name: 'Object graph',
    path: `/tasks/graph/object?global_id=${encodeURIComponent(props.globalId)}`
  }
}))

const menuOptions = computed(() => {
  const tasks = metadata.value.tasks || {}
  const taskSlices = Object.entries(tasks)
    .slice(0, props.maxTaskInPie)
    .map(([task, { name, path }]) => ({
      name: task,
      label: name,
      link: path,
      icon: Icons[task]
        ? {
            url: Icons[task],
            width: '20',
            height: '20'
          }
        : undefined
    }))

  if (Object.keys(tasks).length > props.maxTaskInPie) {
    taskSlices.push({
      label: 'All tasks',
      name: CUSTOM_OPTIONS.AllTasks,
      svgAttributes: {
        class: 'slice'
      },
      icon: {
        url: Icons.AllTasks,
        width: '20',
        height: '20'
      }
    })
  }

  const slices = [...taskSlices, ...defaultSlices.value]

  return {
    width: 500,
    height: 500,
    sliceSize: 190,
    innerPosition: 1.4,
    centerSize: 34,
    margin: 0,
    middleButton: middleButton.value,
    svgAttributes: {
      class: 'svg-radial-menu svg-radial-menu-navigator'
    },
    svgSliceAttributes: {
      fontSize: 11,
      class: 'slice'
    },
    slices
  }
})

const defaultSlices = computed(() => {
  const exclude = [props.exclude].flat()

  if (!metadata.value?.tasks?.unify_objects_task) {
    exclude.push(DEFAULT_OPTIONS.Unify)
  }

  return defaultSlicesTypes
    .filter((type) => !exclude.includes(type))
    .map((type) => addSlice(type, { link: defaultLinks()[type] }))
})

const isPinned = computed(() => metadata.value?.pinboard_item)

const middleButton = computed(() => ({
  name: CUSTOM_OPTIONS.CircleButton,
  radius: 30,
  icon: {
    url: Icons.Pin,
    width: '20',
    height: '20'
  },
  svgAttributes: {
    fill: isPinned.value ? '#F44336' : '#9ccc65'
  }
}))

const isLoading = ref(false)
const isAlltaskSelected = ref(false)
const isRadialOpen = ref(false)
const globalIdSaved = ref(undefined)
const metadata = ref(undefined)
const title = ref('Radial navigation')
const deleted = ref(false)
const showDestroyModal = ref(false)
const radialElement = ref(null)
const defaultSlicesTypes = [
  DEFAULT_OPTIONS.Related,
  DEFAULT_OPTIONS.Unify,
  DEFAULT_OPTIONS.New,
  DEFAULT_OPTIONS.Destroy,
  DEFAULT_OPTIONS.Edit,
  DEFAULT_OPTIONS.Show
]

watch(radialElement, (newVal) => {
  if (newVal) {
    newVal.$el.querySelectorAll('a').forEach((element) => {
      element.addEventListener('click', (event) => {
        const isShortcutKeyPressed =
          event.ctrlKey || event.shiftKey || event.metaKey

        if (isShortcutKeyPressed) {
          isRadialOpen.value = false
        }
      })
    })
  }
})

function addSlice(type, attr) {
  return {
    label: type,
    name: type,
    radius: 30,
    icon: {
      url: Icons[type],
      width: '20',
      height: '20'
    },
    svgAttributes: {
      class: 'slice'
    },
    ...attr
  }
}

function selectedRadialOption({ name }) {
  switch (name) {
    case CUSTOM_OPTIONS.CircleButton:
      isPinned.value ? destroyPin() : createPin()
      break
    case DEFAULT_OPTIONS.Destroy:
      showDestroyModal.value = true
      break
    case CUSTOM_OPTIONS.AllTasks:
      isAlltaskSelected.value = true
      break
  }
}

function defaultLinks() {
  const unifyTask = metadata.value.tasks.unify_objects_task

  const links = {
    [DEFAULT_OPTIONS.Edit]:
      metadata.value?.edit || `${metadata.value?.resource_path}/edit`,
    [DEFAULT_OPTIONS.New]:
      metadata.value?.new ||
      `${metadata.value.resource_path.substring(
        0,
        metadata.value.resource_path.lastIndexOf('/')
      )}/new`,
    [DEFAULT_OPTIONS.Show]: metadata.value.resource_path,
    [DEFAULT_OPTIONS.Related]: `/tasks/shared/related_data?object_global_id=${encodeURIComponent(
      props.globalId
    )}`
  }

  if (unifyTask) {
    Object.assign(links, {
      [DEFAULT_OPTIONS.Unify]: unifyTask.path
    })
  }

  return links
}

function closeModal() {
  isRadialOpen.value = false
  eventClose()
  emit('close')
}

function openRadialMenu() {
  isRadialOpen.value = true
  loadMetadata(props.globalId)
}

function loadMetadata(globalId) {
  if (globalId === globalIdSaved.value && metadata.value) return
  globalIdSaved.value = globalId
  isLoading.value = true

  ajaxCall(
    'get',
    `/metadata/object_radial?global_id=${encodeURIComponent(globalId)}`
  ).then(({ body }) => {
    const { tasks, ...rest } = body

    metadata.value = rest
    metadata.value.tasks = {
      ...tasks,
      ...defaultTasks.value
    }
    title.value = metadata.value.object_label
    isLoading.value = false
  })
}

/* function splitLongWords(taskName) {
  const totalTasks = Object.keys(metadata.value.tasks).length
  const maxPerLine = totalTasks > 4 ? 8 : 16
  const arr = taskName.split(' ')
  const words = []

  arr.forEach((word) => {
    const wordLength = word.length
    const wordArr = []

    for (let i = 0; i < wordLength; i += maxPerLine) {
      wordArr.push(word.slice(i, maxPerLine + i))
    }

    words.push(wordArr.join('- '))
  })

  return words.join(' ')
} */

function eventClose() {
  const event = new CustomEvent('radialObject:close', {
    detail: {
      metadata: metadata.value
    }
  })
  document.dispatchEvent(event)
}

function eventDestroy() {
  const event = new CustomEvent('radialObject:destroy', {
    detail: {
      metadata: metadata.value
    }
  })
  document.dispatchEvent(event)
}

function createPin() {
  const payload = {
    pinned_object_id: metadata.value.id,
    pinned_object_type: metadata.value.type,
    is_inserted: true
  }

  PinboardItem.create({ pinboard_item: payload }).then(({ body }) => {
    metadata.value.pinboard_item = { id: body.id }
    TW.workbench.pinboard.addToPinboard(body)
    TW.workbench.alert.create(
      'Pinboard item was successfully created.',
      'notice'
    )
  })
}

function destroyPin() {
  PinboardItem.destroy(metadata.value.pinboard_item.id).then((_) => {
    TW.workbench.alert.create(
      'Pinboard item was successfully destroyed.',
      'notice'
    )
    TW.workbench.pinboard.removeItem(metadata.value.pinboard_item.id)
    delete metadata.value.pinboard_item
  })
}

function destroyObject() {
  showDestroyModal.value = false
  ajaxCall('delete', `${metadata.value.resource_path}.json`)
    .then((_) => {
      TW.workbench.alert.create(
        `${metadata.value.type} was successfully destroyed.`,
        'notice'
      )
      if (props.globalId === metadata.value.global_id) {
        eventDestroy()
        deleted.value = true
      }
      if (props.redirect) {
        if (metadata.value.destroyed_redirect) {
          window.open(metadata.value.destroyed_redirect, '_self')
        } else if (window.location.pathname === metadata.value.resource_path) {
          window.open(`/${window.location.pathname.split('/')[1]}`, '_self')
        } else {
          window.open(
            metadata.value.resource_path.substring(
              0,
              metadata.value.resource_path.lastIndexOf('/')
            ),
            '_self'
          )
        }
      }
      emit('delete', metadata.value)
      closeModal()
    })
    .catch(() => {})
}
</script>

<script>
export default {
  name: 'RadialNavigation'
}
</script>
<style>
.svg-radial-menu-navigator path {
  stroke: #444;
  stroke-width: 2px;
}
</style>
