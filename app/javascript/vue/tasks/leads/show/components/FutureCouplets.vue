<template>
  <div v-if="couplets.length">
    <div
      v-for="o in couplets.toReversed()"
      :key="o.cpl.id"
      :style="margin_for_depth(o.depth)"
    >
      <a
        :href="RouteNames.ShowLead + '?lead_id=' + o.cpl.id"
        @click="$emit('loadCouplet', o.cpl.id)"
        v-html="lead_tag(o.cpl)"
      />
    </div>
  </div>
</template>

<script setup>
import { lead_tag, margin_for_depth } from '../../helpers/formatters.js'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  couplets: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])
</script>
