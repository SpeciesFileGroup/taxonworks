<template>
  <RadialAnnotator
    v-bind="attrs"
    @create="(e) => emitEvent(DOM_EVENT.Create, e)"
    @change="(e) => emitEvent(DOM_EVENT.Change, e)"
    @close="(e) => emitEvent(DOM_EVENT.Close, e)"
    @delete="(e) => emitEvent(DOM_EVENT.Delete, e)"
    @update="(e) => emitEvent(DOM_EVENT.Update, e)"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'

const DOM_EVENT = {
  Create: 'RadialAnnotator:create',
  Change: 'RadialAnnotator:change',
  Update: 'RadialAnnotator:update',
  Close: 'RadialAnnotator:close',
  Open: 'RadialAnnotator:open'
}

const attrs = useAttrs()

function emitEvent(eventName, data) {
  const event = new CustomEvent(eventName, {
    detail: {
      data,
      appId: attrs.id,
      globalId: attrs.globalId
    }
  })
  document.dispatchEvent(event)
}
</script>
