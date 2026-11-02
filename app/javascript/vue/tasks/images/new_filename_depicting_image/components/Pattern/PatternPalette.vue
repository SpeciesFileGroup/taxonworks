<template>
  <div class="pattern-palette horizontal-left-content middle gap-xsmall">
    <VDraggable
      class="horizontal-left-content middle gap-xsmall"
      :list="FIELD_OPTIONS"
      :group="{ name: 'fields', pull: 'clone', put: false }"
      :clone="(role) => makeField(role)"
      :sort="false"
      :move="canMove"
      :item-key="(role) => role"
    >
      <template #item="{ element }">
        <VBadge
          :class="[
            'palette-item',
            { 'palette-item--disabled': isRoleUsed(element) }
          ]"
          :color="ROLE_COLORS[element]"
          role="button"
          :tabindex="isRoleUsed(element) ? -1 : 0"
          :aria-disabled="isRoleUsed(element)"
          :title="`Add ${ROLE_LABELS[element]}`"
          @click="addFieldIfAvailable(element)"
          @keydown.enter.prevent="addFieldIfAvailable(element)"
          @keydown.space.prevent="addFieldIfAvailable(element)"
        >
          <VIcon
            name="plus"
            xx-small
          />
          <span class="font-bold">{{ ROLE_LABELS[element] }}</span>
        </VBadge>
      </template>
    </VDraggable>
    <span class="palette-divider" />
    <VDraggable
      class="horizontal-left-content middle gap-xsmall"
      :list="SEPARATORS"
      :group="{ name: 'separators', pull: 'clone', put: false }"
      :clone="(value) => makeSeparator(value)"
      :sort="false"
      :item-key="(value) => value"
    >
      <template #item="{ element }">
        <VBadge
          class="palette-item palette-item--separator"
          role="button"
          tabindex="0"
          :title="`Add separator ${displaySeparator(element)}`"
          @click="addSeparator(element)"
          @keydown.enter.prevent="addSeparator(element)"
          @keydown.space.prevent="addSeparator(element)"
        >
          {{ displaySeparator(element) }}
        </VBadge>
      </template>
    </VDraggable>
    <div class="relative">
      <VBtn
        variant="ghost"
        title="Add a custom separator"
        @click="showCustom = true"
      >
        …
      </VBtn>
      <Popup
        v-if="showCustom"
        class="padding-small"
        @close="showCustom = false"
      >
        <SeparatorPicker
          @select="
            (value) => {
              addSeparator(value)
              showCustom = false
            }
          "
        />
      </Popup>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useStore } from '../../store/store'
import { ROLE, ROLE_COLORS, ROLE_LABELS, SEPARATORS } from '../../constants'
import {
  displaySeparator,
  makeField,
  makeSeparator
} from '../../utils/pattern'
import VDraggable from 'vuedraggable'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import Popup from '@/components/ui/Popup/Popup.vue'
import SeparatorPicker from './SeparatorPicker.vue'

const FIELD_OPTIONS = [ROLE.Identifier, ROLE.Label, ROLE.Caption, ROLE.Ignore]

const { addField, addSeparator, isRoleUsed } = useStore()

const showCustom = ref(false)

function canMove({ draggedContext }) {
  return !isRoleUsed(draggedContext.element)
}

function addFieldIfAvailable(role) {
  if (!isRoleUsed(role)) {
    addField(role)
  }
}
</script>

<style scoped>
.pattern-palette {
  flex-wrap: wrap;
}

.palette-item {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  width: auto;
  min-height: var(--size-default);
  border: 1px solid transparent;
  line-height: 1;
  white-space: nowrap;
  cursor: grab;
}

.palette-item--separator {
  justify-content: center;
  min-width: var(--size-default);
  border-color: var(--border-color);
  background-color: transparent;
  color: var(--text-color);
}

.palette-item--disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.palette-divider {
  align-self: stretch;
  margin: 0 0.25rem;
  border-left: 1px solid var(--border-color);
}
</style>
