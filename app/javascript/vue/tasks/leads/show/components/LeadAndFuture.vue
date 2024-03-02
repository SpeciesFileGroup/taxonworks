<template>
  <div>
    <Lead
      :lead="lead"
      :has-future="future.length > 0"
      @load-couplet="(id) => emit('loadCouplet', id)"
    />
    <BlockLayout
      v-if="future.length"
      expand
    >
      <template #header>
        Future Couplets
      </template>
      <template #body>
        <FutureCoupletsList
          :future="future"
          :load-function="(id) => emit('loadCouplet', id)"
          :route-name="RouteNames.ShowLead"
        />

      </template>
    </BlockLayout>
  </div>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureCoupletsList from '../../components/FutureCoupletsList.vue'
import Lead from './Lead.vue'
import { RouteNames } from '@/routes/routes'

const props = defineProps({
  lead: {
    type: Object,
    required: true
  },
  future: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['loadCouplet'])
</script>
