<template>
  <div class="flex-col gap-small">
    <div class="horizontal-left-content middle gap-small">
      <span>{{ objects.length }} {{ noun }}(s)</span>
      <VBtn
        color="primary"
        :disabled="!pendingObjects.length"
        @click="emitAdd(pendingObjects)"
      >
        Add all ({{ pendingObjects.length }})
      </VBtn>
    </div>
    <ul class="light-table-sources__grid">
      <li
        v-for="object in objects"
        :key="object.id"
        class="light-table-sources__thumb"
        :class="{ 'light-table-sources__thumb--placed': isPlaced(object) }"
        :title="
          isPlaced(object) ? 'Already on the light table' : 'Click or drag to add'
        "
        draggable="true"
        @click="emitAdd([object])"
        @dragstart="(e) => onDragStart(e, object)"
      >
        <img
          :src="thumbUrl(object)"
          :alt="object.object_label"
          draggable="false"
        />
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { DRAG_TYPE } from '../../constants'
import { getImage, getThumbUrl } from '../../adapters/source'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  objects: {
    type: Array,
    required: true
  },

  objectType: {
    type: String,
    required: true
  },

  noun: {
    type: String,
    required: true
  },

  placedKeys: {
    type: Set,
    required: true
  }
})

const emit = defineEmits(['add'])

const pendingObjects = computed(() =>
  props.objects.filter((object) => !isPlaced(object))
)

function isPlaced(object) {
  return props.placedKeys.has(`${props.objectType}:${object.id}`)
}

function thumbUrl(object) {
  return getThumbUrl(getImage({ objectType: props.objectType, object }))
}

function payload(list) {
  return {
    objectType: props.objectType,
    objects: list
  }
}

function emitAdd(list) {
  emit('add', payload(list))
}

function onDragStart(event, object) {
  event.dataTransfer.setData(DRAG_TYPE, JSON.stringify(payload([object])))
  event.dataTransfer.effectAllowed = 'copy'
}
</script>

<style scoped>
.light-table-sources__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(72px, 1fr));
  gap: var(--spacing-xxs);
  margin: 0;
  padding: 0;
  list-style: none;
}

.light-table-sources__thumb {
  display: flex;
  align-items: center;
  justify-content: center;
  aspect-ratio: 1;
  overflow: hidden;
  background: var(--bg-muted);
  border: 2px solid transparent;
  border-radius: var(--border-radius-xsmall);
  cursor: grab;
}

.light-table-sources__thumb:hover {
  border-color: var(--color-primary);
}

.light-table-sources__thumb img {
  max-width: 100%;
  max-height: 100%;
}

.light-table-sources__thumb--placed {
  opacity: 0.4;
}
</style>
