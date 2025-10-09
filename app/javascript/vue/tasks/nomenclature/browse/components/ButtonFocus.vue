<template>
  <VBtn
    :class="['margin-small-left', isFocus && 'button-focus--active']"
    circle
    :color="isFocus ? 'disabled' : 'primary'"
    title="Focus this protonym"
    @click="toggleFocus"
  >
    <VIcon
      name="focus"
      x-small
      title="Focus this protonym"
    />
  </VBtn>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const CSS_CLASSES = ['d-none', 'hidden-taxon']
const EVENT_NAME = 'history-focus-button'

const props = defineProps({
  objectId: {
    type: Array,
    required: true
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

    /*     const event = new CustomEvent(EVENT_NAME, {
      detail: {
        focus: false
      }
    }) */

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
.button-focus--active {
  box-shadow: 0 2px 2px 0px rgba(0, 0, 0, 0.2) inset;
}
</style>
