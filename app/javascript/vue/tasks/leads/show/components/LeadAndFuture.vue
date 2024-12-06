<template>
  <div class="lead-and-future">
    <Lead
      :lead="lead"
      :has-future="future.length > 0"
      @load-lead="(id) => emit('loadLead', id)"
    />
    <BlockLayout
      v-if="future.length"
      expand
      class="future"
    >
      <template #header>
        Future Option Sets
      </template>
      <template #body>
        <FutureOptionSetsList
          :future="future"
          :load-function="(id) => emit('loadLead', id)"
          :route-name="RouteNames.ShowLead"
        />

      </template>
    </BlockLayout>
  </div>
</template>

<script setup>
import BlockLayout from '@/components/layout/BlockLayout.vue'
import FutureOptionSetsList from '../../components/FutureOptionSetsList.vue'
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

const emit = defineEmits(['loadLead'])
</script>

<style lang="scss" scoped>
.lead-and-future {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  min-width: 300px;
  // Enough for two full-width medium depictions.
  max-width: calc(600px + 4em + 16px + 4px);
  margin-bottom: 2em;
  background: #f2f2f2;
  padding: 0.5em;
  border-radius: .9rem;
}

.future {
  margin-top: 2em;
}
</style>
