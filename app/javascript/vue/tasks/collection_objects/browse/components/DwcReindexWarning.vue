<template>
  <div
    v-if="dwcObject.rebuild_set"
    class="horizontal-left-content gap-small middle text-warning-color"
  >
    <IconWarning class="w-4 h-4 text-attention-color" />
    DwCOccurrence re-index is pending.
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import IconWarning from '@/components/Icon/IconWarning.vue'

const store = useStore()
const dwcObject = computed(() => store.getters[GetterNames.GetDwc])
</script>
