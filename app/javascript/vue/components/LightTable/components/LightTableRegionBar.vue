<template>
  <div
    v-if="lightTable.regions.length"
    class="lt-region-bar"
  >
    <span class="lt-region-bar__label">{{ labels.regions }}</span>
    <div
      v-for="r in lightTable.regions"
      :key="r.id"
      class="lt-region-chip"
      :style="{ '--lt-region-color': lightTable.regionColor(r) }"
      role="button"
      @click="selectMembers(r.id, $event)"
    >
      <label
        class="lt-region-chip__swatch"
        :title="readonly ? undefined : `Change color of ${r.name}`"
        @click.stop
      >
        <input
          type="color"
          :value="lightTable.regionColor(r)"
          :disabled="readonly"
          @input="(e) => lightTable.updateRegion(r.id, { color: e.target.value })"
        />
      </label>
      <input
        class="lt-region-chip__name"
        type="text"
        :value="r.name"
        :disabled="readonly"
        @click.stop
        @change="(e) => lightTable.updateRegion(r.id, { name: e.target.value })"
      />
      <span
        v-tooltip="`Select ${memberCount(r.id)} image(s) (shift to add)`"
        class="lt-region-chip__count"
      >
        {{ memberCount(r.id) }}
      </span>
      <VBtn
        circle
        small
        variant="ghost"
        color="default"
        title="More options"
        @click.stop="openMenu(r.id, $event)"
      >
        <VIcon
          name="hamburger"
          x-small
        />
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { inject } from 'vue'
import { vTooltip } from '@/directives'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

defineProps({
  readonly: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['context-menu'])

const lightTable = inject('lightTable')
const labels = inject('ltLabels')

function memberCount(regionId) {
  return lightTable.membersOfRegion(regionId).length
}

function openMenu(regionId, event) {
  emit('context-menu', {
    target: { kind: 'region', id: regionId },
    element: event.currentTarget
  })
}

function selectMembers(regionId, event) {
  const ids = lightTable.membersOfRegion(regionId).map((it) => it.id)

  if (event?.shiftKey) lightTable.addToSelection(ids)
  else lightTable.selectOnly(ids)
}
</script>

<style scoped>
.lt-region-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--spacing-xxs) var(--spacing-xs);
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-xs);
  border-bottom: 1px solid var(--border-color);
}

.lt-region-bar__label {
  margin-right: var(--spacing-xxs);
  color: var(--text-muted-color);
}

.lt-region-chip {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 2px 2px 2px 6px;
  background: var(--bg-muted);
  border: 1px solid var(--border-color);
  border-left: 4px solid var(--lt-region-color);
  border-radius: var(--border-radius-small);
  cursor: pointer;
  user-select: none;
}

.lt-region-chip:hover {
  background: var(--bg-hover);
}

.lt-region-chip__swatch {
  position: relative;
  overflow: hidden;
  width: 14px;
  height: 14px;
  background: var(--lt-region-color);
  border-radius: 3px;
  cursor: pointer;
}

.lt-region-chip__swatch:focus-within {
  outline: 2px solid var(--focus-ring);
  outline-offset: 1px;
}

.lt-region-chip__swatch input {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  padding: 0;
  border: none;
  opacity: 0;
  cursor: pointer;
}

.lt-region-chip__name {
  width: 130px;
  min-width: 60px;
  padding: 2px 4px;
  font: inherit;
  color: inherit;
  background: transparent;
  border: none;
  border-radius: 3px;
  cursor: text;
}

.lt-region-chip__name:hover,
.lt-region-chip__name:focus {
  background: var(--input-bg-color);
}

.lt-region-chip__count {
  min-width: 20px;
  padding: 2px 6px;
  line-height: 1;
  text-align: center;
  white-space: nowrap;
  font-weight: 600;
  background: var(--bg-foreground);
  border-radius: 999px;
}
</style>
