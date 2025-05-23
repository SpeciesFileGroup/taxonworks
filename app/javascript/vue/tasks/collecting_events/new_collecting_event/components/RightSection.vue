<template>
  <div
    class="right-section"
    ref="root"
  >
    <div ref="section">
      <PanelSoftValidation
        :validations="softValidation"
        class="soft-validation-box margin-medium-top"
      />
      <MatchesComponent
        class="margin-medium-top"
        :collecting-event="store.collectingEvent"
        @select="(e) => emit('select', e)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, onBeforeUnmount, useTemplateRef } from 'vue'
import { SoftValidation } from '@/routes/endpoints'
import MatchesComponent from './Matches'
import PanelSoftValidation from '@/components/soft_validations/panel'
import useStore from '@/components/Form/FormCollectingEvent/store/collectingEvent.js'

const emit = defineEmits(['select'])

const store = useStore()

const softValidation = ref({})
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

function loadSoftValidation(globalId) {
  SoftValidation.find(globalId).then(({ body }) => {
    if (body.soft_validations.length) {
      softValidation.value = {
        collectingEvent: { list: [body], title: 'Collecting event' }
      }
    }
  })
}
store.$onAction(({ name, after }) => {
  const actions = ['save', 'load']
  after(() => {
    if (actions.includes(name)) {
      const globalId = store.collectingEvent.global_id

      if (globalId) {
        loadSoftValidation(globalId)
      }
    }
  })
})

watch(
  () => store.collectingEvent.id,
  (newVal) => {
    if (!newVal) {
      softValidation.value = {}
    }
  }
)
</script>

<style lang="scss" scoped>
.right-section {
  position: relative;
  width: 400px;
  min-width: 400px;
}
.float-box {
  top: 55px;
  width: 400px;
  min-width: 400px;
  position: fixed;
}
</style>
