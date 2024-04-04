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
              @onClick="selectRadialOption"
            />
          </div>
        </template>
      </VModal>
      <AllTasks
        v-if="isAlltaskSelected"
        :tasks="metadata.tasks"
        @select="openLink"
        @close="() => (isAlltaskSelected = false)"
      />

      <VBtn
        title="Radial navigator"
        color="radial"
        circle
        :disabled="disabled"
        @click="openRadialMenu()"
      >
        <VIcon
          title="Radial navigator"
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
import Icons from '../navigation/images/icons.js'
import AllTasks from './components/allTasks.vue'
import { humanize, capitalize } from '@/helpers/strings.js'
import { Metadata } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import VModal from '@/components/ui/Modal.vue'

const CUSTOM_OPTIONS = {
  AllTasks: 'allTasks'
}

defineOptions({
  name: 'RadialNavigation'
})

const props = defineProps({
  ids: {
    type: Array,
    default: () => []
  },

  maxTaskInPie: {
    type: Number,
    default: 4
  },

  model: {
    type: String,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'delete'])

const menuOptions = computed(() => {
  const { base = {}, tasks = {} } = metadata.value

  const baseSlices = Object.entries(base)
    .slice(0, props.maxTaskInPie)
    .map(([task, url]) => ({
      name: {
        url,
        task
      },
      label: humanize(task),
      icon: Icons[capitalize(task)]
        ? {
            url: Icons[capitalize(task)],
            width: '20',
            height: '20'
          }
        : undefined
    }))

  const taskSlices = Object.entries(tasks)
    .slice(0, props.maxTaskInPie)
    .map(([task, url]) => ({
      name: {
        url,
        task
      },
      label: humanize(task)
    }))

  if (Object.keys(tasks).length > props.maxTaskInPie) {
    taskSlices.push({
      label: 'All tasks',
      name: { task: CUSTOM_OPTIONS.AllTasks },
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

  const slices = [...taskSlices, ...baseSlices]

  return {
    width: 500,
    height: 500,
    sliceSize: 190,
    innerPosition: 1.4,
    centerSize: 34,
    margin: 0,
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

const isLoading = ref(false)
const isAlltaskSelected = ref(false)
const isRadialOpen = ref(false)
const metadata = ref(undefined)
const title = ref('Radial navigation')
const deleted = ref(false)
const radialElement = ref(null)

function openLink(url) {
  props.ids.forEach((id) => {
    window.open(`${url}?${metadata.value.id}=${id}`, '_blank')
  })
}

function selectRadialOption({ name: { task, url } }) {
  switch (task) {
    case CUSTOM_OPTIONS.AllTasks:
      isAlltaskSelected.value = true
      break
    default:
      openLink(url)
  }
}

function closeModal() {
  isRadialOpen.value = false
  emit('close')
}

function openRadialMenu() {
  isRadialOpen.value = true

  if (!metadata.value) {
    loadMetadata(props.model)
  }
}

function loadMetadata(model) {
  isLoading.value = true
  Metadata.classNavigation({ klass: model })
    .then(({ body }) => {
      metadata.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}
</script>
<style>
.svg-radial-menu-navigator path {
  stroke: #444;
  stroke-width: 2px;
}
</style>
