<template>
  <template v-if="couplets.length">
    <div
      v-for="o in couplets.toReversed()"
      :key="o.cpl.id"
      :style="marginForDepth(o.depth)"
    >
      <a
        :href="RouteNames.ShowLead + '?lead_id=' + o.cpl.id"
        @click="() => emit('loadCouplet', o.cpl.id)"
        v-html="leadText(o.cpl)"
      />
    </div>
  </template>
</template>

<script setup>
import { leadText, marginForDepth } from '../../helpers/formatters.js'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  couplets: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])
</script>
