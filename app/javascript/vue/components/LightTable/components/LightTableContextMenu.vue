<template>
  <ContextMenu
    ref="contextMenuRef"
    class="lt-context-menu"
  >
    <template v-if="target?.kind === 'item'">
      <div class="lt-context-menu__header">
        {{
          selectedItems.length === 1
            ? selectedItems[0].label || selectedItems[0].alt || 'Image'
            : `${selectedItems.length} images`
        }}
      </div>
      <div
        v-if="$slots.item"
        class="lt-context-menu__section"
      >
        <slot
          name="item"
          :items="selectedItems"
        />
      </div>
      <template v-if="!readonly">
        <div class="lt-context-menu__section">
          <LightTableSubmenu label="Arrange">
            <LightTableMenuItem
              label="Bring to front"
              @click="lightTable.bringToFront()"
            />
            <LightTableMenuItem
              label="Bring forward"
              @click="lightTable.bringForward()"
            />
            <LightTableMenuItem
              label="Send backward"
              @click="lightTable.sendBackward()"
            />
            <LightTableMenuItem
              label="Send to back"
              @click="lightTable.sendToBack()"
            />
          </LightTableSubmenu>
          <LightTableSubmenu label="Transform">
            <LightTableMenuItem
              label="Rotate 90° left"
              @click="lightTable.rotateSelected(-90)"
            />
            <LightTableMenuItem
              label="Rotate 90° right"
              @click="lightTable.rotateSelected(90)"
            />
            <LightTableMenuItem
              label="Rotate 180°"
              @click="lightTable.rotateSelected(180)"
            />
            <LightTableMenuItem
              label="Scale 1:1"
              @click="lightTable.setScale(1)"
            />
            <LightTableMenuItem
              label="Reset transform"
              @click="lightTable.resetTransform()"
            />
          </LightTableSubmenu>
          <LightTableSubmenu label="Opacity">
            <LightTableMenuItem
              v-for="value in OPACITIES"
              :key="value"
              :label="`${value}%`"
              @click="lightTable.setOpacity(value / 100)"
            />
          </LightTableSubmenu>
          <LightTableSubmenu :label="labels.region">
            <LightTableMenuItem
              :label="`New ${regionLabel} with selection`"
              @click="
                lightTable.regionFromSelection({ name: `New ${regionLabel}` })
              "
            />
            <LightTableMenuItem
              :label="`Remove from ${regionLabel}`"
              :disabled="!selectedItems.some((it) => it.regionId)"
              @click="lightTable.unassignSelected()"
            />
            <LightTableSubmenu
              label="Move to"
              :disabled="!lightTable.regions.length"
            >
              <LightTableMenuItem
                v-for="destination in lightTable.regions"
                :key="destination.id"
                :disabled="
                  selectedItems.every((it) => it.regionId === destination.id)
                "
                @click="
                  lightTable.assignToRegion(
                    [...lightTable.selection],
                    destination.id
                  )
                "
              >
                <span
                  class="lt-context-menu__swatch"
                  :style="{
                    backgroundColor: lightTable.regionColor(destination)
                  }"
                />
                {{ destination.name || `Unnamed ${regionLabel}` }}
              </LightTableMenuItem>
            </LightTableSubmenu>
          </LightTableSubmenu>
          <LightTableSubmenu
            v-if="selectedItems.length > 1"
            label="Align"
          >
            <LightTableMenuItem
              v-for="edge in ALIGN_EDGES"
              :key="edge.value"
              :label="edge.label"
              @click="lightTable.alignSelected(edge.value)"
            />
            <LightTableMenuItem
              label="Distribute horizontally"
              :disabled="selectedItems.length < 3"
              @click="lightTable.distributeSelected('horizontal')"
            />
            <LightTableMenuItem
              label="Distribute vertically"
              :disabled="selectedItems.length < 3"
              @click="lightTable.distributeSelected('vertical')"
            />
          </LightTableSubmenu>
        </div>
      </template>
      <div class="lt-context-menu__section">
        <LightTableMenuItem
          v-if="!readonly"
          label="Edit label"
          :disabled="selectedItems.length !== 1"
          @click="lightTable.requestEdit('item', target.id)"
        />
        <LightTableMenuItem
          label="Fit selection"
          @click="lightTable.fitSelection()"
        />
        <LightTableMenuItem
          v-if="!readonly"
          label="Remove from table"
          shortcut="Del"
          @click="lightTable.removeItems([...lightTable.selection])"
        />
      </div>
    </template>

    <template v-else-if="target?.kind === 'region' && region">
      <div class="lt-context-menu__header">
        {{ region.name || `Unnamed ${regionLabel}` }}
      </div>
      <div
        v-if="$slots.region"
        class="lt-context-menu__section"
      >
        <slot
          name="region"
          :region="region"
          :items="lightTable.membersOfRegion(region.id)"
        />
      </div>
      <div
        v-if="!readonly"
        class="lt-context-menu__section"
      >
        <LightTableSubmenu
          label="Layout"
          :disabled="!memberIds.length"
        >
          <LightTableMenuItem
            v-for="arrangement in ARRANGEMENTS"
            :key="arrangement.layout"
            :label="arrangement.label"
            @click="
              lightTable.packRegion(region.id, { layout: arrangement.layout })
            "
          />
        </LightTableSubmenu>
      </div>
      <div class="lt-context-menu__section">
        <LightTableMenuItem
          v-if="!readonly"
          label="Rename"
          @click="lightTable.requestEdit('region', region.id)"
        />
        <LightTableMenuItem
          label="Select images"
          :disabled="!memberIds.length"
          @click="lightTable.selectOnly(memberIds)"
        />
        <LightTableMenuItem
          :label="`Fit ${regionLabel}`"
          @click="lightTable.fitRegion(region.id)"
        />
        <LightTableMenuItem
          v-if="!readonly"
          :label="`Remove ${regionLabel} (images are kept)`"
          @click="lightTable.removeRegion(region.id)"
        />
      </div>
    </template>

    <template v-else-if="target?.kind === 'canvas'">
      <div
        v-if="$slots.canvas"
        class="lt-context-menu__section"
      >
        <slot
          name="canvas"
          :point="target.point"
        />
      </div>
      <div class="lt-context-menu__section">
        <LightTableMenuItem
          label="Select all"
          shortcut="Ctrl+A"
          :disabled="!lightTable.items.length"
          @click="lightTable.selectOnly(lightTable.items.map((it) => it.id))"
        />
        <LightTableMenuItem
          label="Clear selection"
          shortcut="Esc"
          :disabled="!lightTable.selection.size"
          @click="lightTable.clearSelection()"
        />
        <LightTableMenuItem
          label="Fit all"
          @click="lightTable.fitAll()"
        />
        <LightTableMenuItem
          label="Reset view"
          @click="lightTable.viewport.reset()"
        />
        <LightTableMenuItem
          v-if="!readonly"
          :label="`New ${regionLabel} here`"
          @click="createRegionAt(target.point)"
        />
      </div>
    </template>
  </ContextMenu>
</template>

<script setup>
import { inject, computed, ref } from 'vue'
import ContextMenu from '@/components/ui/Context/ContextMenu.vue'
import LightTableMenuItem from './LightTableMenuItem.vue'
import LightTableSubmenu from './LightTableSubmenu.vue'

const OPACITIES = [25, 50, 100]

const ARRANGEMENTS = [
  { layout: 'grid', label: 'Grid' },
  { layout: 'row', label: 'Row' },
  { layout: 'column', label: 'Column' }
]

const ALIGN_EDGES = [
  { value: 'left', label: 'Align left' },
  { value: 'hcenter', label: 'Align horizontal centers' },
  { value: 'right', label: 'Align right' },
  { value: 'top', label: 'Align top' },
  { value: 'vcenter', label: 'Align vertical centers' },
  { value: 'bottom', label: 'Align bottom' }
]

defineProps({
  readonly: {
    type: Boolean,
    default: false
  }
})

const lightTable = inject('lightTable')
const labels = inject('ltLabels')

const contextMenuRef = ref(null)
const target = ref(null)

const regionLabel = computed(() => labels.value.region.toLowerCase())
const selectedItems = computed(() => lightTable.selectedItems.value)

const region = computed(() =>
  target.value?.kind === 'region'
    ? lightTable.regions.find((r) => r.id === target.value.id)
    : null
)

const memberIds = computed(() =>
  region.value
    ? lightTable.membersOfRegion(region.value.id).map((it) => it.id)
    : []
)

function createRegionAt(point) {
  lightTable.createRegion({
    name: `New ${regionLabel.value}`,
    x: point.x,
    y: point.y
  })
}

function open(newTarget, event) {
  target.value = newTarget
  contextMenuRef.value.openContextMenu({ x: event.clientX, y: event.clientY })
}

defineExpose({ open })
</script>

<style scoped>
.lt-context-menu {
  z-index: 1000;
  width: auto;
  min-width: 220px;
  overflow: visible;
  border-radius: var(--border-radius-small);
}

.lt-context-menu__header {
  padding: var(--spacing-xs) var(--spacing-sm);
  overflow: hidden;
  font-size: var(--font-size-xs);
  font-weight: 600;
  white-space: nowrap;
  text-overflow: ellipsis;
  border-bottom: 1px solid var(--border-color);
}

.lt-context-menu__section {
  padding: var(--spacing-xxs) 0;
  border-bottom: 1px solid var(--border-color);
}

.lt-context-menu__section:last-child {
  border-bottom: none;
}


.lt-context-menu__swatch {
  display: inline-block;
  width: 10px;
  height: 10px;
  margin-right: var(--spacing-xxs);
  border-radius: 2px;
}
</style>
