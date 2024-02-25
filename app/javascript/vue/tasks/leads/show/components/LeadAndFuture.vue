<template>
  <div>
    <Lead
      :lead="lead"
      :has-future="future.length > 0"
      @load-couplet="(id) => $emit('loadCouplet', id)"
    />
    <BlockLayout
      v-if="future.length"
      expand
    >
      <template #header>
        Future Couplets
      </template>
      <template #body>
        <FutureCouplets
          :couplets="future"
          @loadCouplet="(id) => emit('loadCouplet', id)"
        />
      </template>
    </BlockLayout>
  </div>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureCouplets from './FutureCouplets.vue'
import Lead from './Lead.vue'

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