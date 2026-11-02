<template>
  <VDraggable
    :list="store.composition"
    class="pattern-composition horizontal-left-content middle gap-xsmall padding-small"
    :group="{ name: 'composition', put: ['fields', 'separators'] }"
    filter=".composition-popup"
    :prevent-on-filter="false"
    item-key="id"
  >
    <template #item="{ element, index }">
      <CompositionField
        v-if="element.kind === 'field'"
        :field="element"
        :index="index"
        @remove="store.removeCompositionItem(index)"
      />
      <CompositionSeparator
        v-else
        :separator="element"
        @remove="store.removeCompositionItem(index)"
      />
    </template>
    <template #footer>
      <span
        v-if="!store.composition.length"
        class="text-sm"
      >
        Click or drag fields and separators here
      </span>
    </template>
  </VDraggable>
</template>

<script setup>
import { useStore } from '../../store/store'
import VDraggable from 'vuedraggable'
import CompositionField from './CompositionField.vue'
import CompositionSeparator from './CompositionSeparator.vue'

const store = useStore()
</script>

<style scoped>
.pattern-composition {
  flex-wrap: wrap;
  gap: 0.75rem;
  min-height: 3rem;
  border: 1px dashed var(--border-color);
  border-radius: 4px;
}

.pattern-composition :deep(.composition-item) {
  position: relative;
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

.pattern-composition :deep(.composition-item--separator) {
  justify-content: center;
  min-width: var(--size-default);
  border-color: var(--border-color);
  background-color: transparent;
  color: var(--text-color);
}

.pattern-composition :deep(.composition-item--optional) {
  border-style: dashed;
  border-color: currentColor;
}

.pattern-composition :deep(.composition-item--selected) {
  outline: 2px solid var(--color-primary);
  outline-offset: 1px;
}

.pattern-composition :deep(.composition-remove) {
  position: absolute;
  top: 0;
  right: 0;
  transform: translate(50%, -50%);
  visibility: hidden;
}

.pattern-composition :deep(.composition-item:hover .composition-remove),
.pattern-composition :deep(.composition-item:focus-within .composition-remove) {
  visibility: visible;
}

.pattern-composition :deep(.composition-popup) {
  top: 100%;
  left: 0;
  margin-top: 0.25rem;
  cursor: auto;
}
</style>
