<template>
  <div class="packager-downloads margin-large-bottom">
    <div class="flex-separate middle">
      <h2>Download packages</h2>
      <div class="packager-downloads__controls display-flex align-center gap-medium">
        <label class="display-flex align-center gap-small">
          Max MB
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

    <ul v-if="groups.length" class="packager-downloads__list">
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
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import { formatBytes, buildDownloadFilename, clampMaxMb } from './utils'

const props = defineProps({
  groups: {
    type: Array,
    required: true
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

const emit = defineEmits(['update:maxMb', 'refresh', 'download'])

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
</script>

<style scoped>
.packager-downloads__disabled {
  color: #666;
  cursor: not-allowed;
  text-decoration: line-through;
}
</style>
