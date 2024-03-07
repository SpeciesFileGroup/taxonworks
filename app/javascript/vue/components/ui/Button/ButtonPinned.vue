<template>
  <VBtn
    :disabled="!pinnedId"
    circle
    color="primary"
    :title="buttonTitle"
    @click="sendDefault"
  >
    <VIcon
      small
      color="white"
      name="pin"
      :title="buttonTitle"
    />
  </VBtn>
</template>
<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { computed, ref, onBeforeMount, onBeforeUnmount } from 'vue'

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
  }
})

const emit = defineEmits(['getId', 'getLabel', 'getItem'])

const buttonTitle = computed(() =>
  pinnedId.value
    ? `Use [${pinnedLlabel.value}]`
    : `Make default ${props.type} from pinboard to use it`
)

const pinnedLlabel = ref(null)
const pinnedId = ref(null)

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
