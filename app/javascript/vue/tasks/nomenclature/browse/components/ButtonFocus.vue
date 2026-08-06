<template>
  <VBtn
    v-if="protonym"
    :class="[{ 'button-focus--active': isFocus }, 'margin-xsmall-right']"
    icon
    color="primary"
    variant="tonal"
    :title="isFocus ? 'Remove focus from this protonym' : 'Focus this protonym'"
    @click="toggleFocus"
  >
    <IconFocus class="w-4 h-4" />
  </VBtn>
  <div
    v-else
    class="empty-focus-container"
  ></div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconFocus from '@/components/Icon/IconFocus.vue'

const CSS_CLASSES = ['d-none', 'hidden-taxon']
const EVENT_NAME = 'history-focus-button'

const props = defineProps({
  objectId: {
    type: Array,
    required: true
  },

  protonym: {
    type: Boolean,
    default: false
  }
})

defineOptions({
  name: 'FocusButton'
})

const isFocus = ref(false)

onMounted(() => document.addEventListener(EVENT_NAME, setFocusState))
onBeforeUnmount(() => document.removeEventListener(EVENT_NAME, setFocusState))

function setFocusState(e) {
  isFocus.value = e.detail.focus
}

function toggleFocus() {
  const elements = [...document.querySelectorAll('.history__record')]
  const hasHiddenColumns = elements.some((el) =>
    el.classList.contains('hidden-taxon')
  )

  const event = new CustomEvent(EVENT_NAME, {
    detail: {
      focus: !isFocus.value
    }
  })
  document.dispatchEvent(event)

  if (hasHiddenColumns) {
    elements.forEach((el) => {
      CSS_CLASSES.forEach((c) => el.classList.remove(c))
    })

    document.dispatchEvent(event)

    return
  }

  elements.forEach((el) => {
    const ids = el.getAttribute('data-history-protonym-id')?.split(',')

    if (ids.some((id) => props.objectId.includes(id))) {
      CSS_CLASSES.forEach((c) => el.classList.remove(c))
    } else {
      CSS_CLASSES.forEach((c) => el.classList.add(c))
    }
  })

  window.scrollTo(0, 0)
}
</script>

<style scoped>
.empty-focus-container {
  width: 24px;
  height: 24px;
  margin-right: var(--spacing-xxs);
}

.button-focus--active {
  background-color: var(--bg-active);
  border: 2px solid var(--border-active);
}
</style>
