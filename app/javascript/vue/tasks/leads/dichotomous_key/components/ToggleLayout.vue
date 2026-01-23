<template>
  <VBtn
    color="primary"
    @click="toggleLayout"
  >
    <div :class="['dichotomous-grid', 'w-3', 'h-3', inverseLayout]">
      <div class="panel-key"></div>
      <div class="panel-remaining"></div>
      <div class="panel-eliminated"></div>
    </div>
  </VBtn>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import useSettingStore from '../store/settings.js'

const store = useSettingStore()

const inverseLayout = computed(() =>
  store.layout == 'layout-1' ? 'layout-2' : 'layout-1'
)

function toggleLayout() {
  store.layout = inverseLayout.value
}
</script>
