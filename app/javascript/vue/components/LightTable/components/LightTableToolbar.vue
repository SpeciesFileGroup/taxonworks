<template>
  <div class="lt-toolbar">
    <div class="lt-toolbar__group">
      <VBtn
        v-for="b in ORDER_BUTTONS"
        :key="b.label"
        variant="outline"
        color="default"
        :disabled="!hasSelection || readonly"
        @click="lightTable[b.action]()"
      >
        {{ b.label }}
      </VBtn>
    </div>

    <div class="lt-toolbar__group">
      <VBtn
        variant="outline"
        color="default"
        :disabled="!hasSelection || readonly"
        @click="lightTable.resetTransform()"
      >
        Reset transform
      </VBtn>
      <label
        class="lt-toolbar__opacity"
        :class="{ 'lt-toolbar__opacity--disabled': !hasSelection }"
        :title="`Opacity ${Math.round(opacity * 100)}%`"
      >
        Opacity
        <input
          type="range"
          min="10"
          max="100"
          step="5"
          :value="Math.round(opacity * 100)"
          :disabled="!hasSelection || readonly"
          @input="onOpacityInput"
        />
      </label>
    </div>

    <div
      v-if="!readonly"
      class="lt-toolbar__group"
    >
      <VBtn
        variant="outline"
        color="default"
        :title="
          hasSelection
            ? `Create a ${regionLabel} containing the selection`
            : `Create an empty ${regionLabel}`
        "
        @click="lightTable.regionFromSelection({ name: `New ${regionLabel}` })"
      >
        New {{ regionLabel }}
      </VBtn>
      <VBtn
        variant="outline"
        color="default"
        :disabled="!hasSelection"
        :title="`Move the selected images to the ${regionLabel} they were dropped on`"
        @click="lightTable.claimSelected()"
      >
        Claim
      </VBtn>
      <VBtn
        variant="outline"
        color="default"
        :disabled="!hasSelection"
        :title="`Remove the selected images from their ${regionLabel}`"
        @click="lightTable.unassignSelected()"
      >
        Unassign
      </VBtn>
      <VBtn
        variant="outline"
        color="destroy"
        :disabled="!hasSelection"
        title="Remove the selected images from the table"
        @click="lightTable.removeItems([...lightTable.selection])"
      >
        Remove
      </VBtn>
    </div>

    <div
      v-if="canAlign && !readonly"
      class="lt-toolbar__group"
    >
      <VBtn
        v-for="b in ALIGN_BUTTONS"
        :key="b.action"
        circle
        variant="outline"
        color="default"
        :title="b.title"
        @click="lightTable.alignSelected(b.action)"
      >
        <svg
          width="14"
          height="14"
          viewBox="0 0 16 16"
        >
          <path
            fill="currentColor"
            :d="b.path"
          />
        </svg>
      </VBtn>
      <VBtn
        v-for="b in DISTRIBUTE_BUTTONS"
        :key="b.action"
        circle
        variant="outline"
        color="default"
        :disabled="!canDistribute"
        :title="b.title"
        @click="lightTable.distributeSelected(b.action)"
      >
        <svg
          width="14"
          height="14"
          viewBox="0 0 16 16"
        >
          <path
            fill="currentColor"
            :d="b.path"
          />
        </svg>
      </VBtn>
    </div>

    <div class="lt-toolbar__group">
      <VBtn
        variant="outline"
        color="default"
        title="Zoom to fit all content"
        @click="lightTable.fitAll()"
      >
        Fit all
      </VBtn>
      <VBtn
        variant="outline"
        color="default"
        :disabled="!hasSelection"
        title="Zoom to fit the selection"
        @click="lightTable.fitSelection()"
      >
        Fit selection
      </VBtn>
      <VBtn
        variant="outline"
        color="default"
        @click="lightTable.viewport.reset()"
      >
        Reset view
      </VBtn>
    </div>

    <slot name="append" />
  </div>
</template>

<script setup>
import { inject, computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const ORDER_BUTTONS = [
  { label: 'To front', action: 'bringToFront' },
  { label: 'Forward', action: 'bringForward' },
  { label: 'Backward', action: 'sendBackward' },
  { label: 'To back', action: 'sendToBack' }
]

const ALIGN_BUTTONS = [
  {
    action: 'left',
    title: 'Align left',
    path: 'M2 2v12h1V2zM5 4h7v2H5zM5 9h4v2H5z'
  },
  {
    action: 'hcenter',
    title: 'Align horizontal centers',
    path: 'M7.5 2h1v12h-1zM4.5 4h7v2h-7zM6 9h4v2H6z'
  },
  {
    action: 'right',
    title: 'Align right',
    path: 'M13 2v12h1V2zM5 4h7v2H5zM8 9h4v2H8z'
  },
  {
    action: 'top',
    title: 'Align top',
    path: 'M2 2h12v1H2zM4 4h2v7H4zM9 4h2v4H9z'
  },
  {
    action: 'vcenter',
    title: 'Align vertical centers',
    path: 'M2 7.5h12v1H2zM4 4.5h2v7H4zM9 6h2v4H9z'
  },
  {
    action: 'bottom',
    title: 'Align bottom',
    path: 'M2 13h12v1H2zM4 5h2v7H4zM9 8h2v4H9z'
  }
]

const DISTRIBUTE_BUTTONS = [
  {
    action: 'horizontal',
    title: 'Distribute horizontally',
    path: 'M2 3h2v10H2zM7 3h2v10H7zM12 3h2v10h-2z'
  },
  {
    action: 'vertical',
    title: 'Distribute vertically',
    path: 'M3 2h10v2H3zM3 7h10v2H3zM3 12h10v2H3z'
  }
]

defineProps({
  readonly: {
    type: Boolean,
    default: false
  }
})

const lightTable = inject('lightTable')
const labels = inject('ltLabels')

const regionLabel = computed(() => labels.value.region.toLowerCase())
const hasSelection = computed(() => lightTable.selection.size > 0)
const canAlign = computed(() => lightTable.selection.size >= 2)
const canDistribute = computed(() => lightTable.selection.size >= 3)

const opacity = computed(() => lightTable.selectedItems.value[0]?.opacity ?? 1)

function onOpacityInput(event) {
  lightTable.setOpacity(Number(event.target.value) / 100)
}
</script>

<style scoped>
.lt-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--spacing-xs) var(--spacing-md);
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-xs);
  border-bottom: 1px solid var(--border-color);
}

.lt-toolbar__group {
  display: flex;
  align-items: center;
  gap: var(--spacing-xxs);
}

.lt-toolbar__opacity {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xxs);
  color: var(--text-color);
}

.lt-toolbar__opacity input[type='range'] {
  width: 90px;
  cursor: pointer;
}

.lt-toolbar__opacity--disabled {
  color: var(--text-muted-color);
  cursor: not-allowed;
}
</style>
