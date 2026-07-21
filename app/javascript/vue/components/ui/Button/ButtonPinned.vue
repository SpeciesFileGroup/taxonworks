<template>
  <VBtn
    v-if="pinnedId || showWhenUnpinned"
    :disabled="disabled || !pinnedId"
    medium
    variant="tonal"
    color="primary"
    icon
    :title="buttonTitle"
    @click="sendDefault"
  >
    <IconPin class="w-4 h-4" />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import IconPin from '@/components/Icon/IconPin.vue'
import { computed, ref, onBeforeMount, onBeforeUnmount, watch } from 'vue'

const props = defineProps({
  section: {
    type: String,
    required: true
  },

  label: {
    type: String,
    default: ''
  },

  type: {
    type: String,
    required: true
  },

  disabled: {
    type: Boolean,
    default: false
  },

  // When false (default) the button is hidden unless an element is pinned;
  // set true to keep it visible-but-disabled while nothing is pinned.
  showWhenUnpinned: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['getId', 'getLabel', 'getItem', 'pinned', 'unpinned'])

const buttonTitle = computed(() =>
  pinnedId.value
    ? `Use [${pinnedLlabel.value}]`
    : `Make default ${props.type} from pinboard to use it`
)

const pinnedLlabel = ref(null)
const pinnedId = ref(null)

watch(
  () => props.section,
  () => {
    if (props.section) loadPinnedObject()
  }
)

watch(
  pinnedId,
  (id) => {
    if (id) {
      emit('pinned', { id, label: pinnedLlabel.value })
    } else {
      emit('unpinned')
    }
  },
  { immediate: true }
)

onBeforeMount(() => {
  loadPinnedObject()
  document.addEventListener('pinboard:insert', handleEvent)
})

onBeforeUnmount(() => {
  document.removeEventListener('pinboard:insert', handleEvent)
})

function sendDefault() {
  if (pinnedId.value) {
    emit('getId', pinnedId.value)
  }
  if (pinnedLlabel.value) {
    emit('getLabel', pinnedLlabel.value)
  }
  if (pinnedLlabel.value && pinnedId.value) {
    emit('getItem', { id: pinnedId.value, label: pinnedLlabel.value })
  }
}

function loadPinnedObject() {
  const defaultElement = document.querySelector(
    `[data-pinboard-section="${props.section}"] [data-insert="true"]`
  )

  pinnedId.value = defaultElement?.dataset?.pinboardObjectId
  pinnedLlabel.value = defaultElement?.querySelector('a')?.textContent
}

function handleEvent(event) {
  if (event.detail.type === props.type) {
    loadPinnedObject()
  }
}
</script>
