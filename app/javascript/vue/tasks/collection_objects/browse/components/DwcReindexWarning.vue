<template>
  <div
    v-if="dwcObject.rebuild_set"
    class="horizontal-left-content gap-small middle text-warning-color"
  >
    <VIcon
      name="attention"
      small
      color="warning"
    />
    DwCOccurrence re-index is pending.
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import VIcon from '@/components/ui/VIcon/index.vue'

const store = useStore()
const dwcObject = computed(() => store.getters[GetterNames.GetDwc])
</script>
