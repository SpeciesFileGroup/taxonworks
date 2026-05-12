<template>
  <details class="nesting-order-form">
    <summary class="nesting-order-summary">Nesting order</summary>

    <div class="nesting-order-body">
      <div class="nesting-columns">
        <div class="nesting-column">
          <h4 class="nesting-column-label">Active (ordered)</h4>
          <draggable
            v-model="activeOrder"
            group="nesting"
            item-key="key"
            class="nesting-list"
            handle=".drag-handle"
          >
            <template #item="{ element }">
              <div class="nesting-item nesting-item--active">
                <span class="drag-handle">&#8597;</span>
                <span class="nesting-item-label">{{ element.label }}</span>
                <button
                  type="button"
                  class="nesting-remove"
                  title="Remove"
                  @click="removeItem(element)"
                >&#x2715;</button>
              </div>
            </template>
          </draggable>
        </div>

        <div class="nesting-column">
          <h4 class="nesting-column-label">Available</h4>
          <draggable
            v-model="availableItems"
            group="nesting"
            item-key="key"
            class="nesting-list"
          >
            <template #item="{ element }">
              <div class="nesting-item nesting-item--available">
                <span class="nesting-item-label">{{ element.label }}</span>
                <button
                  type="button"
                  class="nesting-add"
                  title="Add"
                  @click="addItem(element)"
                >&#x2b;</button>
              </div>
            </template>
          </draggable>
        </div>
      </div>

      <div class="nesting-actions">
        <button
          type="button"
          class="button button-submit"
          @click="apply"
        >Apply</button>
        <button
          type="button"
          class="button normal-input button-default"
          @click="reset"
        >Reset to default</button>
      </div>
    </div>
  </details>
</template>

<script setup>
import { ref, computed } from 'vue'
import Draggable from 'vuedraggable'
import { NESTING_VARIABLES, DEFAULT_NESTING_ORDER } from '../constants/nestingVariables.js'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => [...DEFAULT_NESTING_ORDER]
  }
})

const emit = defineEmits(['update:modelValue'])

function buildActive(order) {
  return order
    .map(k => NESTING_VARIABLES.find(v => v.key === k))
    .filter(Boolean)
}

function buildAvailable(order) {
  return NESTING_VARIABLES.filter(v => !order.includes(v.key))
}

const activeOrder  = ref(buildActive(props.modelValue))
const availableItems = ref(buildAvailable(props.modelValue))

function removeItem(item) {
  activeOrder.value = activeOrder.value.filter(v => v.key !== item.key)
  availableItems.value = NESTING_VARIABLES.filter(
    v => !activeOrder.value.some(a => a.key === v.key)
  )
}

function addItem(item) {
  activeOrder.value = [...activeOrder.value, item]
  availableItems.value = availableItems.value.filter(v => v.key !== item.key)
}

function apply() {
  emit('update:modelValue', activeOrder.value.map(v => v.key))
}

function reset() {
  activeOrder.value   = buildActive(DEFAULT_NESTING_ORDER)
  availableItems.value = buildAvailable(DEFAULT_NESTING_ORDER)
  emit('update:modelValue', [...DEFAULT_NESTING_ORDER])
}
</script>

<style scoped>
.nesting-order-form {
  margin-bottom: 1.2em;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 0.6em 0.8em;
  background: #fafafa;
}

.nesting-order-summary {
  cursor: pointer;
  font-weight: bold;
  font-size: 0.95em;
  user-select: none;
}

.nesting-order-body {
  margin-top: 0.8em;
}

.nesting-columns {
  display: flex;
  gap: 1.2em;
  flex-wrap: wrap;
}

.nesting-column {
  flex: 1;
  min-width: 180px;
}

.nesting-column-label {
  margin: 0 0 0.4em;
  font-size: 0.85em;
  text-transform: uppercase;
  color: #666;
  letter-spacing: 0.04em;
}

.nesting-list {
  min-height: 2em;
  border: 1px solid #e0e0e0;
  border-radius: 3px;
  background: #fff;
  padding: 0.3em;
}

.nesting-item {
  display: flex;
  align-items: center;
  gap: 0.4em;
  padding: 0.25em 0.4em;
  border-radius: 2px;
  margin-bottom: 0.2em;
  font-size: 0.9em;
}

.nesting-item--active {
  background: #edf4ff;
}

.nesting-item--available {
  background: #f5f5f5;
}

.drag-handle {
  cursor: grab;
  color: #999;
  font-size: 1.1em;
  line-height: 1;
}

.nesting-item-label {
  flex: 1;
}

.nesting-remove,
.nesting-add {
  background: none;
  border: none;
  cursor: pointer;
  color: #888;
  font-size: 0.95em;
  padding: 0 0.2em;
  line-height: 1;
}

.nesting-remove:hover { color: #c00; }
.nesting-add:hover    { color: #080; }

.nesting-actions {
  display: flex;
  gap: 0.6em;
  margin-top: 0.8em;
}
</style>
