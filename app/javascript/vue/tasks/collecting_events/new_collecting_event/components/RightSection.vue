<template>
  <div
    class="right-section"
    ref="root"
  >
    <div ref="section">
      <MatchesComponent
        :collecting-event="store.collectingEvent"
        @select="(e) => emit('select', e)"
      />
    </div>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, useTemplateRef } from 'vue'
import MatchesComponent from './Matches'
import useStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'

const emit = defineEmits(['select'])

const store = useStore()

const section = useTemplateRef('section')
const root = useTemplateRef('root')

onMounted(() => {
  window.addEventListener('scroll', scrollBox)
})

function scrollBox() {
  if (root.value) {
    if (root.value.offsetTop < document.documentElement.scrollTop + 50) {
      section.value.classList.add('float-box')
    } else {
      section.value.classList.remove('float-box')
    }
  }
}

onBeforeUnmount(() => window.removeEventListener('scroll', scrollBox))
</script>

<style lang="scss" scoped>
.right-section {
  position: relative;
  width: 400px;
  min-width: 400px;
}
.float-box {
  top: calc(54px + 1em);
  width: 400px;
  min-width: 400px;
  position: fixed;
}
</style>
