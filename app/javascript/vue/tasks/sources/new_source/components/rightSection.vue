<template>
  <div
    ref="root"
    class="right-section"
  >
    <div
      class="overflow-y-auto"
      ref="section"
    >
      <VDocuments
        ref="documents"
        class="panel"
      />
      <SoftValidation
        v-if="store.softValidation"
        class="margin-medium-top soft-validation-panel"
        :validations="store.softValidation"
      />
      <PanelMatches
        class="margin-medium-top"
        ref="matches"
      />
    </div>
  </div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, useTemplateRef } from 'vue'
import { useStickyBelow } from '@/composables'
import { useSourceStore } from '../store'
import VDocuments from './documents'
import SoftValidation from '@/components/soft_validations/panel'
import PanelMatches from './PanelMatches.vue'

const store = useSourceStore()
const sectionRef = useTemplateRef('section')
const documentsRef = useTemplateRef('documents')
const matchesRef = useTemplateRef('matches')
const rootRef = useTemplateRef('root')

useStickyBelow(rootRef, sectionRef)

function scrollBox() {
  const sectionSize = sectionRef.value.getBoundingClientRect()
  const documentsSize = documentsRef.value.$el.getBoundingClientRect()
  const matchesSize = matchesRef.value.$el.getBoundingClientRect()
  const validationsSize =
    document.querySelector('.soft-validation-panel')?.getBoundingClientRect()
      ?.height || 0

  const totalHeight =
    documentsSize.height + validationsSize + matchesSize.height
  const newHeight =
    window.innerHeight - sectionSize.top < totalHeight
      ? `${window.innerHeight - sectionSize.top}px`
      : 'auto'

  sectionRef.value.style.height = newHeight
}

onMounted(() => {
  window.addEventListener('scroll', scrollBox)
  scrollBox()
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', scrollBox)
})
</script>

<style lang="scss" scoped>
.right-section {
  position: relative;
  min-width: 400px;
  max-width: 400px;
}
</style>
