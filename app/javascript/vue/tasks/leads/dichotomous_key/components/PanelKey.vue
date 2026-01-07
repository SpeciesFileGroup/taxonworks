<template>
  <div
    ref="treeContainer"
    class="content"
  >
    <VSpinner
      v-if="loading"
      full-screen
    />

    <KeyCouplet
      v-if="keyTree"
      :node="keyTree"
      @scroll:couplet="scrollToCouplet"
    />
  </div>
</template>

<script setup>
import { computed, useTemplateRef } from 'vue'
import useStore from '../store/lead.js'
import KeyCouplet from './KeyCouplet.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const store = useStore()
const treeContainerRef = useTemplateRef('treeContainer')
const loading = computed(() => store.loading)
const keyTree = computed(() => store.keyTree)

function scrollToCouplet(couplet) {
  const el = treeContainerRef.value.querySelector(`#cplt-${couplet}`)

  if (el) {
    el.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}
</script>
