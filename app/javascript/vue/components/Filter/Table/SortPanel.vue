<template>
  <div
    ref="wrapperRef"
    class="sort-panel-wrapper"
  >
    <VBtn
      :color="sortKeys.length ? 'toggle-active' : 'primary'"
      circle
      :title="buttonTitle"
      @click="onButtonClick"
    >
      <VIcon
        name="alphabeticalSort"
        x-small
      />
    </VBtn>
    <div
      v-if="isOpen"
      class="sort-panel"
    >
      <div class="sort-panel__header padding-small">
        <strong>Sort</strong>
      </div>
      <div
        v-if="!sortKeys.length && !availableToAdd.length"
        class="sort-panel__empty padding-medium"
      >
        No sorts applied. Click a column sort button to add one.
      </div>
      <div
        v-else-if="!sortKeys.length"
        class="sort-panel__empty padding-medium"
      >
        No sorts applied. Pick a column below to add one, or click a column sort button.
      </div>
      <ul
        v-else
        class="no-list-style padding-xsmall"
      >
        <li
          v-for="(entry, index) in sortKeys"
          :key="entry.key"
          class="horizontal-left-content gap-small padding-xsmall"
        >
          <span class="sort-panel__precedence">{{ index + 1 }}</span>
          <span class="flex-grow-1">{{ labelFor(entry.key) }}</span>
          <VBtn
            :color="'primary'"
            circle
            :title="entry.dir === 'asc' ? 'Ascending — click to flip' : 'Descending — click to flip'"
            @click="flipDir(index)"
          >
            <VIcon
              :name="entry.dir === 'asc' ? 'arrowUp' : 'arrowDown'"
              x-small
            />
          </VBtn>
          <VBtn
            color="primary"
            circle
            :disabled="index === 0"
            title="Move up in precedence"
            @click="move(index, -1)"
          >
            ↑
          </VBtn>
          <VBtn
            color="primary"
            circle
            :disabled="index === sortKeys.length - 1"
            title="Move down in precedence"
            @click="move(index, 1)"
          >
            ↓
          </VBtn>
          <VBtn
            color="toggle-active"
            circle
            title="Remove this sort key"
            @click="remove(index)"
          >
            <VIcon
              name="close"
              x-small
            />
          </VBtn>
        </li>
      </ul>
      <div
        v-if="availableToAdd.length"
        class="sort-panel__adder horizontal-left-content gap-small padding-small"
      >
        <select
          v-model="pendingAddKey"
          class="flex-grow-1"
        >
          <option value="">Add sort column…</option>
          <option
            v-for="opt in availableToAdd"
            :key="opt.key"
            :value="opt.key"
          >{{ opt.label }}</option>
        </select>
        <VBtn
          color="primary"
          :disabled="!pendingAddKey"
          title="Add this column to the sort"
          @click="addPending"
        >
          Add
        </VBtn>
      </div>
      <div
        v-if="sortKeys.length"
        class="sort-panel__footer padding-small"
      >
        <VBtn
          color="toggle-active"
          title="Clear all sort keys (shortcut: shift-click the sort button)"
          @click="clearAll"
        >
          Clear all sorts
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, useTemplateRef } from 'vue'
import { humanize } from '@/helpers/strings'
import { useClickOutside } from '@/composables/useClickOutside.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  labels: {
    type: Object,
    default: () => ({})
  }
})

const sortKeys = defineModel('sortKeys', {
  type: Array,
  default: () => []
})

const wrapperRef = useTemplateRef('wrapperRef')
const isOpen = ref(false)
const pendingAddKey = ref('')

useClickOutside(wrapperRef, () => {
  isOpen.value = false
})

const availableToAdd = computed(() => {
  const activeKeys = new Set(sortKeys.value.map((s) => s.key))
  return Object.entries(props.labels)
    .filter(([key]) => !activeKeys.has(key))
    .map(([key, label]) => ({ key, label }))
    .sort((a, b) => a.label.localeCompare(b.label))
})

function addPending() {
  if (!pendingAddKey.value) return
  sortKeys.value = [...sortKeys.value, { key: pendingAddKey.value, dir: 'asc' }]
  pendingAddKey.value = ''
}

const buttonTitle = computed(() => {
  if (!sortKeys.value.length) return 'Sort — click to open panel'
  return `Sort — ${sortKeys.value.length} active. Click to open, shift-click to clear all.`
})

function onButtonClick(event) {
  if (event.shiftKey) {
    if (sortKeys.value.length) sortKeys.value = []
    isOpen.value = false
    return
  }
  isOpen.value = !isOpen.value
}

function labelFor(key) {
  return props.labels[key] || humanize(key.replace(/\./g, ' '))
}

function flipDir(index) {
  const next = [...sortKeys.value]
  next[index] = { ...next[index], dir: next[index].dir === 'asc' ? 'desc' : 'asc' }
  sortKeys.value = next
}

function move(index, delta) {
  const target = index + delta
  if (target < 0 || target >= sortKeys.value.length) return
  const next = [...sortKeys.value]
  const [entry] = next.splice(index, 1)
  next.splice(target, 0, entry)
  sortKeys.value = next
}

function remove(index) {
  const next = [...sortKeys.value]
  next.splice(index, 1)
  sortKeys.value = next
}

function clearAll() {
  sortKeys.value = []
  isOpen.value = false
}
</script>

<style scoped>
.sort-panel-wrapper {
  position: relative;
  display: inline-block;
}
.sort-panel {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  z-index: 100;
  min-width: 320px;
  background: var(--panel-bg-color, #fff);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
.sort-panel__header {
  border-bottom: 1px solid var(--border-color);
}
.sort-panel__empty {
  color: var(--text-color-muted, #888);
}
.sort-panel__footer {
  border-top: 1px solid var(--border-color);
}
.sort-panel__precedence {
  font-weight: 700;
  min-width: 1.25em;
  text-align: right;
}
.no-list-style {
  list-style: none;
  margin: 0;
}
</style>
