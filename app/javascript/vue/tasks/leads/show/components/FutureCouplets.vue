<template>
  <div v-if="couplets.length">
    <div
      v-for="o in couplets.toReversed()"
      :key="o.cpl.id"
      :style="margin_for_depth(o.depth)"
    >
      <span class="link cursor-pointer"
        @click="$emit('loadCouplet', o.cpl.id)"
        v-html="lead_tag(o.cpl)"
      />
    </div>
  </div>
</template>

<script setup>
import { lead_tag, margin_for_depth } from '../../helpers/formatters.js'

const props = defineProps({
  couplets: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])
</script>
