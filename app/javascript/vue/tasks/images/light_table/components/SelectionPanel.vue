<template>
  <div class="panel content">
    <h3>Selection</h3>
    <p v-if="!items.length">
      Nothing selected. Click an image, or drag on the table to select several.
    </p>
    <ul
      v-else
      class="light-table-selection"
    >
      <li
        v-for="item in items"
        :key="item.id"
        class="margin-small-bottom"
      >
        <div>
          <span class="text-xs">{{ item.meta.objectType }}</span>
          <a
            :href="item.meta.object.object_url"
            v-html="item.meta.object.object_tag"
          />
        </div>
        <div v-if="item.meta.object.depiction_object">
          <span class="text-xs">Depicts</span>
          <a
            :href="item.meta.object.depiction_object.object_url"
            v-html="item.meta.object.depiction_object.object_tag"
          />
        </div>
        <div v-if="regionNames[item.regionId]">
          <span class="text-xs">{{ LABELS.region }}</span>
          {{ regionNames[item.regionId] }}
        </div>
        <a
          class="text-xs"
          :href="`${RouteNames.BrowseImage}?image_id=${imageId(item)}`"
        >Browse image</a>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { RouteNames } from '@/routes/routes'
import { LABELS, OBJECT_DEPICTION } from '../constants'

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },

  regions: {
    type: Array,
    default: () => []
  }
})

const regionNames = computed(() =>
  Object.fromEntries(props.regions.map((r) => [r.id, r.name]))
)

function imageId(item) {
  return item.meta.objectType === OBJECT_DEPICTION
    ? item.meta.object.image_id
    : item.meta.objectId
}
</script>

<style scoped>
.light-table-selection {
  margin: 0;
  padding-left: var(--spacing-md);
}

.light-table-selection .text-xs {
  margin-right: var(--spacing-xxs);
  color: var(--text-muted-color);
}
</style>
