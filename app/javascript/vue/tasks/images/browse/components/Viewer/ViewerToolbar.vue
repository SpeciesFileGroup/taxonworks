<template>
  <div class="toolbar panel">
    <button
      v-for="{ mode, title, icon } in TOOLS"
      :key="mode"
      :title="title"
      :class="{ active: currentMode === mode }"
      @click="() => (currentMode = mode)"
    >
      <VIcon
        v-if="typeof icon === 'string'"
        small
        :name="icon"
      />
      <component
        :is="icon"
        class="w-4 h-4"
        v-else
      />
    </button>
  </div>
</template>

<script setup>
const currentMode = defineModel({ default: 'pan' })
import VIcon from '@/components/ui/VIcon/index.vue'
import IconRubber from '@/components/Icon/IconRubber.vue'
import IconRuler from '@/components/Icon/IconRuler.vue'

const TOOLS = [
  {
    mode: 'pan',
    title: 'Pan',
    icon: `move`
  },
  {
    mode: 'measure',
    title: 'Measurement tool',
    icon: IconRuler
  },
  {
    mode: 'erase',
    title: 'Erase measure',
    icon: IconRubber
  },
  {
    mode: 'zoom',
    title: 'Zoom',
    icon: `zoomIn`
  }
]
</script>

<style scoped>
.toolbar {
  display: flex;
  flex-direction: column;
  box-shadow: var(--panel-shadow);
  padding: 0.5rem;
  gap: 0.5rem;

  button {
    background-color: var(--bg-foreground);
    color: var(--text-color);
    border: 0px;
    padding: 0.5rem;
    cursor: pointer;
    width: 32px;
    height: 32px;
    border-radius: var(--border-radius-medium);
  }

  .active {
    background-color: var(--color-active);
  }
}
</style>
