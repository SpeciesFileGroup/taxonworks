<template>
  <div class="panel content">
    <h3>Selection</h3>
    <p v-if="!items.length">
      Nothing selected. Click an image, or drag on the table to select several.
    </p>
    <template v-else>
      <div class="flex-separate middle">
        <p class="text-xs light-table-selection__count">
          {{ items.length }} selected
        </p>
        <SelectionRadials :items="items" />
      </div>
      <div
        v-for="row in rows"
        :key="row.item.id"
        class="light-table-selection__row"
      >
        <button
          type="button"
          class="light-table-selection__thumb"
          title="Select only this image"
          @click="emit('select', row.item.id)"
        >
          <img
            :src="row.thumbUrl"
            :alt="row.object.object_label"
          />
        </button>
        <div class="light-table-selection__text">
          <span v-html="row.object.object_tag" />
          <span
            v-if="row.details"
            class="text-xs light-table-selection__details"
          >
            {{ row.details }}
          </span>
        </div>
        <VBtn
          circle
          small
          variant="ghost"
          color="default"
          title="Deselect"
          @click="emit('deselect', row.item.id)"
        >
          <VIcon
            name="close"
            x-small
          />
        </VBtn>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { DEPICTION } from '@/constants'
import { getImage, getThumbUrl } from '../adapters/source'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import SelectionRadials from './SelectionRadials.vue'

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

const emit = defineEmits(['select', 'deselect'])

const regionNames = computed(() =>
  Object.fromEntries(props.regions.map((r) => [r.id, r.name]))
)

const rows = computed(() =>
  props.items.map((item) => {
    const { object } = item.meta
    const isDepiction = item.meta.objectType === DEPICTION
    const image = getImage(item.meta)

    return {
      item,
      object: (isDepiction && object.depiction_object) || image,
      thumbUrl: getThumbUrl(image),
      details: [item.label, regionNames.value[item.regionId]]
        .filter(Boolean)
        .join(' · ')
    }
  })
)
</script>

<style scoped>
.light-table-selection__count {
  margin: 0;
  color: var(--text-muted-color);
}

.light-table-selection__row {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: var(--spacing-xxs) 0;
  border-top: 1px solid var(--border-color);
}

.light-table-selection__text {
  display: flex;
  flex: 1;
  flex-direction: column;
  min-width: 0;
  overflow-wrap: anywhere;
}

.light-table-selection__details {
  color: var(--text-muted-color);
}

.light-table-selection__thumb {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  padding: 0;
  overflow: hidden;
  background: var(--bg-muted);
  border: 2px solid transparent;
  border-radius: var(--border-radius-xsmall);
  cursor: pointer;
}

.light-table-selection__thumb:hover,
.light-table-selection__thumb:focus-visible {
  border-color: var(--color-primary);
}

.light-table-selection__thumb img {
  max-width: 100%;
  max-height: 100%;
}
</style>
