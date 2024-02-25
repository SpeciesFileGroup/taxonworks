<template>
  <div v-if="futureCouplets.length">
    <div
      v-for="o in futureCouplets.toReversed()"
      :key="o.cpl.id"
      :style="margin_for_depth(o.depth)"
    >
      <span class="link cursor-pointer"
        @click="store.loadKey(o.cpl.id)"
        v-html="lead_tag(o.cpl)"
      />
    </div>
  </div>
  <div v-else v-html="'<i>No future couplets</i>'" />
</template>

<script setup>
import { computed } from 'vue'
import { lead_tag, margin_for_depth } from '../../helpers/formatters.js'
import { useStore } from '../store/useStore.js'

const props = defineProps({
  side: {
    type: String,
    required: true,
    validator(value) {
      return ['left', 'right'].includes(value)
    }
  }
})

const store = useStore()

const futureCouplets = computed(() => { return store[props.side + '_future'] })
</script>
