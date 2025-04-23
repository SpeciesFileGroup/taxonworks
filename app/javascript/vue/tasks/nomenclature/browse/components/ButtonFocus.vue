<template>
  <VBtn
    class="margin-small-left"
    circle
    color="primary"
    title="Focus this protonym"
    @click="setFocus"
  >
    <VIcon
      name="focus"
      x-small
      title="Focus this protonym"
    />
  </VBtn>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const CSS_CLASSES = ['d-none', 'hidden-taxon']

const props = defineProps({
  objectId: {
    type: Array,
    required: true
  }
})

defineOptions({
  name: 'FocusButton'
})

function setFocus() {
  const elements = [...document.querySelectorAll('.history__record')]
  const hasHiddenColumns = elements.some((el) =>
    el.classList.contains('hidden-taxon')
  )

  if (hasHiddenColumns) {
    elements.forEach((el) => {
      CSS_CLASSES.forEach((c) => el.classList.remove(c))
    })

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
