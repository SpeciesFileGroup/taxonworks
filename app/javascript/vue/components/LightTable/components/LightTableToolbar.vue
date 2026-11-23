<template>
  <div class="lt-toolbar">
    <template v-if="!readonly">
      <LightTableToolbarGroup>
        <VBtn
          variant="outline"
          color="default"
          title="Change the stacking order of the selection"
          :disabled="!hasSelection"
          @click.stop="(e) => orderMenuRef.openBelow(e.currentTarget)"
        >
          Order
          <VIcon
            class="margin-xsmall-left"
            name="arrowDown"
            xx-small
          />
        </VBtn>
        <LightTableMenu ref="orderMenuRef">
          <LightTableMenuItem
            v-for="item in ORDER_ITEMS"
            :key="item.action"
            :label="item.label"
            @click="lightTable[item.action]()"
          />
        </LightTableMenu>
      </LightTableToolbarGroup>

      <LightTableToolbarGroup>
        <VBtn
          variant="outline"
          color="default"
          :disabled="!hasSelection"
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
            :disabled="!hasSelection"
            @input="onOpacityInput"
          />
        </label>
      </LightTableToolbarGroup>

      <LightTableToolbarGroup>
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
      </LightTableToolbarGroup>

      <LightTableToolbarGroup>
        <VBtn
          variant="outline"
          color="destroy"
          :disabled="!hasSelection"
          title="Remove the selected images from the table"
          @click="lightTable.removeItems([...lightTable.selection])"
        >
          Remove
        </VBtn>
      </LightTableToolbarGroup>
    </template>

    <LightTableToolbarGroup>
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
    </LightTableToolbarGroup>

    <slot name="append" />
  </div>
</template>

<script setup>
import { inject, computed, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import LightTableMenu from './LightTableMenu.vue'
import LightTableMenuItem from './LightTableMenuItem.vue'
import LightTableToolbarGroup from './LightTableToolbarGroup.vue'

const ORDER_ITEMS = [
  { label: 'Bring to front', action: 'bringToFront' },
  { label: 'Bring forward', action: 'bringForward' },
  { label: 'Send backward', action: 'sendBackward' },
  { label: 'Send to back', action: 'sendToBack' }
]

defineProps({
  readonly: {
    type: Boolean,
    default: false
  }
})

const lightTable = inject('lightTable')
const labels = inject('ltLabels')
const orderMenuRef = ref(null)

const regionLabel = computed(() => labels.value.region.toLowerCase())
const hasSelection = computed(() => lightTable.selection.size > 0)

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
  gap: var(--spacing-xs) var(--spacing-sm);
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-xs);
  border-bottom: 1px solid var(--border-color);
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
