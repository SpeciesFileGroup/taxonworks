<template>
  <VBtn
    v-if="!isLoading"
    color="primary"
    medium
    @click="
      () => {
        isLoading = true
        emit('click')
      }
    "
  >
    Load others
  </VBtn>
  <div
    v-else
    class="otu_spinner"
  >
    <VSpinner
      :show-legend="false"
      :logo-size="{ width: '14px', height: '14px' }"
      :legend-style="{ display: 'none' }"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['click'])

const isLoading = ref(false)
</script>

<style lange="scss" scoped>
.otu_spinner {
  display: inline-block;
  width: 14px;
  height: 14px;
}
</style>
