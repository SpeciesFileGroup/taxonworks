<template>
  <div class="packager-downloads margin-large-bottom">
    <div class="packager-downloads__grid">
      <h2 class="packager-downloads__title">Download packages</h2>
      <VBtn
        v-if="showBack"
        class="packager-downloads__back"
        :disabled="!canGoBack"
        color="primary"
        @click="onBack"
      >
        Back to {{ filterName }}
      </VBtn>

      <div class="packager-downloads__list">
        <ul v-if="groups.length">
          <li
            v-for="group in groups"
            :key="group.index"
            class="packager-downloads__item margin-small-bottom"
          >
            <template v-if="group.available_count > 0">
              <VBtn
                color="primary"
                @click="onDownload(group.index)"
              >
                {{ buildDownloadFilename(filenamePrefix, group.index, groups.length) }}
              </VBtn>
            </template>

            <template v-else>
              <span class="packager-downloads__disabled">
                {{ buildDownloadFilename(filenamePrefix, group.index, groups.length) }}
              </span>
            </template>

            <span class="margin-small-left">
              {{ group.available_count || 0 }} available of
              {{ itemCount(group) }} {{ itemLabel }} ·
              {{ formatBytes(group.size) }} (estimated uncompressed)
            </span>
          </li>
        </ul>
        <p v-else>{{ emptyMessage }}</p>
      </div>

      <div class="packager-downloads__controls display-flex align-center gap-medium">
        <label class="display-flex align-center gap-small">
          Max MB per download
          <input
            type="number"
            class="normal-input"
            :value="maxMb"
            min="10"
            max="1000"
            @input="onMaxMbInput"
          />
        </label>
        <VBtn
          color="primary"
          @click="onRefresh"
        >
          Update downloads
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import { formatBytes, buildDownloadFilename, clampMaxMb } from './utils'

const props = defineProps({
  groups: {
    type: Array,
    required: true
  },
  filterName: {
    type: String,
    default: ''
  },
  canGoBack: {
    type: Boolean,
    default: true
  },
  showBack: {
    type: Boolean,
    default: true
  },
  maxMb: {
    type: Number,
    required: true
  },
  filenamePrefix: {
    type: String,
    required: true
  },
  itemLabel: {
    type: String,
    default: 'items'
  },
  itemCountKey: {
    type: String,
    default: 'item_ids'
  },
  emptyMessage: {
    type: String,
    default: 'No items found.'
  }
})

const emit = defineEmits(['update:maxMb', 'refresh', 'download', 'back'])

function itemCount(group) {
  const key = props.itemCountKey
  if (group[key]) {
    return group[key].length
  }
  return 0
}

function onMaxMbInput(event) {
  emit('update:maxMb', clampMaxMb(Number(event.target.value)))
}

function onRefresh() {
  emit('refresh')
}

function onDownload(index) {
  emit('download', index)
}

function onBack() {
  emit('back')
}
</script>

<style scoped>
.packager-downloads__grid {
  display: grid;
  grid-template-columns: 1fr auto;
  grid-template-rows: auto auto;
  column-gap: 1.5rem;
  row-gap: 0;
  align-items: start;
  margin-bottom: 1rem;
}

.packager-downloads__title {
  grid-column: 1 / 2;
  grid-row: 1 / 2;
  align-self: center;
}

.packager-downloads__back {
  grid-column: 2 / 3;
  grid-row: 1 / 2;
  justify-self: end;
  align-self: center;
}

.packager-downloads__list {
  grid-column: 1 / 2;
  grid-row: 2 / 3;
}

.packager-downloads__controls {
  grid-column: 2 / 3;
  grid-row: 2 / 3;
  justify-self: end;
}

.packager-downloads__disabled {
  color: #666;
  cursor: not-allowed;
  text-decoration: line-through;
}
</style>
