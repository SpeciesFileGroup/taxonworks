<template>
  <div
    v-if="area"
    class="lt-region"
    :style="style"
  >
    <div
      class="lt-region__header"
      @pointerdown="onHeaderPointerDown"
    >
      <input
        v-if="editingName"
        ref="nameInputEl"
        v-model="nameDraft"
        type="text"
        class="lt-region__name-input"
        @blur="commitName"
        @keydown.enter.prevent="commitName"
        @keydown.escape.prevent="cancelName"
        @click.stop
        @pointerdown.stop
      />
      <span
        v-else
        class="lt-region__name"
        :title="region.name"
        @dblclick.stop="startNameEdit"
      >{{ region.name || `Unnamed ${labels.region.toLowerCase()}` }}</span>
      <span
        class="lt-region__count"
        :title="`${memberCount} member(s)`"
      >
        {{ memberCount }}
      </span>
      <template v-if="!readonly">
        <VBtn
          v-if="memberCount"
          circle
          x-small
          variant="ghost"
          color="default"
          title="Arrange images in a grid"
          @click.stop="lightTable.packRegion(region.id)"
          @pointerdown.stop
        >
          <VIcon
            name="expand"
            xx-small
          />
        </VBtn>
        <VBtn
          circle
          x-small
          variant="ghost"
          color="default"
          :title="`Remove ${labels.region.toLowerCase()} (images are kept)`"
          @click.stop="lightTable.removeRegion(region.id)"
          @pointerdown.stop
        >
          <VIcon
            name="close"
            xx-small
          />
        </VBtn>
      </template>
    </div>
  </div>
</template>

<script setup>
import { inject, computed, ref, nextTick } from 'vue'
import { usePointerDrag } from '../composables/usePointerDrag.js'
import { REGION_HEADER_H } from '../utils/geometry.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  region: {
    type: Object,
    required: true
  },

  readonly: {
    type: Boolean,
    default: false
  }
})

const lightTable = inject('lightTable')
const labels = inject('ltLabels')

const area = computed(() => lightTable.regionArea(props.region.id))

const memberCount = computed(
  () => lightTable.membersOfRegion(props.region.id).length
)

const style = computed(() => ({
  left: `${area.value.x}px`,
  top: `${area.value.y}px`,
  width: `${area.value.w}px`,
  height: `${area.value.h}px`,
  '--lt-region-color': props.region.color,
  '--lt-region-header-h': `${REGION_HEADER_H}px`
}))

const startMove = usePointerDrag({
  onMove({ delta }) {
    const zoom = lightTable.viewport.state.zoom
    lightTable.moveRegion(props.region.id, delta.x / zoom, delta.y / zoom)
  }
})

function onHeaderPointerDown(event) {
  if (props.readonly) return
  startMove(event)
}

const editingName = ref(false)
const nameDraft = ref('')
const nameInputEl = ref(null)

function startNameEdit() {
  if (props.readonly) return
  nameDraft.value = props.region.name
  editingName.value = true
  nextTick(() => {
    nameInputEl.value?.focus()
    nameInputEl.value?.select()
  })
}

function commitName() {
  if (!editingName.value) return
  lightTable.updateRegion(props.region.id, { name: nameDraft.value })
  editingName.value = false
}

function cancelName() {
  editingName.value = false
}
</script>

<style scoped>
.lt-region {
  position: absolute;
  box-sizing: border-box;
  background: color-mix(in srgb, var(--lt-region-color) 6%, transparent);
  border: 2px dashed var(--lt-region-color);
  border-radius: var(--border-radius-xsmall);
  pointer-events: none;
}

.lt-region__header {
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  display: flex;
  align-items: center;
  gap: 6px;
  height: var(--lt-region-header-h);
  padding: 0 8px;
  font-size: var(--font-size-xs);
  font-weight: 600;
  color: var(--text-color);
  background: color-mix(
    in srgb,
    var(--lt-region-color) 22%,
    var(--bg-foreground)
  );
  border-top: 3px solid var(--lt-region-color);
  border-radius: var(--border-radius-xsmall) var(--border-radius-xsmall) 0 0;
  box-sizing: border-box;
  pointer-events: auto;
  user-select: none;
  cursor: grab;
}

.lt-region__header:active {
  cursor: grabbing;
}

.lt-region__name {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  cursor: text;
}

.lt-region__name-input {
  flex: 1;
  min-width: 60px;
  padding: 1px 4px;
  font: inherit;
  color: var(--text-color);
  background: var(--input-bg-color);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius-xsmall);
}

.lt-region__count {
  padding: 1px 8px;
  line-height: 1.4;
  white-space: nowrap;
  background: var(--bg-muted);
  border-radius: 999px;
}
</style>
