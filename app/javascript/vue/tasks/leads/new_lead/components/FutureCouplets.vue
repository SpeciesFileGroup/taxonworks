<template>
  <div v-if="futureCouplets.length">
    <div
      v-for="o in futureCouplets.toReversed()"
      :key="o.cpl.id"
      :style="marginForDepth(o.depth)"
    >
      <a
        :href="RouteNames.NewLead + '?lead_id=' + o.cpl.parent_id"
        @click.prevent="store.loadKey(o.cpl.parent_id)"
        v-html="coupletText(o.cpl, o.cplLabel)"
      />
    </div>
  </div>
  <div
    v-else
    v-html="'<i>No future couplets</i>'"
  />
</template>

<script setup>
import { computed } from 'vue'
import { coupletText, marginForDepth } from '../../helpers/formatters.js'
import { RouteNames } from '@/routes/routes'
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
