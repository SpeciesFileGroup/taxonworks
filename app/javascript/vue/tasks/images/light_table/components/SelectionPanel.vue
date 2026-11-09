<template>
  <div class="panel content">
    <h3>Selection</h3>
    <p v-if="!items.length">
      Nothing selected. Click an image, or drag on the table to select several.
    </p>
    <template v-else>
      <div class="flex-separate middle margin-small-bottom">
        <p class="text-xs light-table-selection__count">
          {{ items.length }} selected
        </p>
        <div class="horizontal-right-content middle gap-small">
          <VBtn
            color="primary"
            @click="emit('apply-otu')"
          >
            Assign OTU...
          </VBtn>
          <SelectionRadials :items="items" />
        </div>
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
            :alt="row.image.object_label"
          />
        </button>
        <div class="light-table-selection__text">
          <span
            v-for="object in row.objects"
            :key="object.global_id"
            v-html="object.object_tag"
          />
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

const emit = defineEmits(['select', 'deselect', 'apply-otu'])

const regionNames = computed(() =>
  Object.fromEntries(props.regions.map((r) => [r.id, r.name]))
)

const rows = computed(() =>
  props.items.map((item) => {
    const image = getImage(item.meta)
    const depictedObjects = (item.meta.depictions || [])
      .map((d) => d.depiction_object)
      .filter(Boolean)

    return {
      item,
      image,
      objects: depictedObjects.length ? depictedObjects : [image],
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
