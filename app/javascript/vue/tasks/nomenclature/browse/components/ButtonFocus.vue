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

  elements.forEach((el) => {
    const id = Number(el.getAttribute('data-history-object-id'))

    if (props.objectId.includes(id)) {
      el.classList.remove('d-none')
    } else {
      el.classList.add('d-none')
    }
  })
}
</script>
