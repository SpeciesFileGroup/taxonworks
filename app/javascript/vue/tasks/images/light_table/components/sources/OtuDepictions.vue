<template>
  <div class="flex-col gap-small">
    <VAutocomplete
      url="/otus/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search an OTU..."
      clear-after
      @select="selectOtu"
    />

    <template v-if="otu">
      <div class="horizontal-left-content middle gap-small">
        <span
          class="full_width"
          v-html="otu.label_html"
        />
        <VBtn
          circle
          color="primary"
          variant="ghost"
          title="Clear"
          @click="clear"
        >
          <VIcon
            name="close"
            x-small
          />
        </VBtn>
      </div>

      <VSpinner v-if="isLoading" />
      <p v-else-if="!depictions.length">No depictions for this OTU.</p>
      <template v-else>
        <div class="horizontal-left-content middle gap-small">
          <span>{{ depictions.length }} depiction(s)</span>
          <VBtn
            color="primary"
            :disabled="!pendingDepictions.length"
            @click="emitAdd(pendingDepictions)"
          >
            Add all ({{ pendingDepictions.length }})
          </VBtn>
        </div>
        <ul class="light-table-sources__grid">
          <li
            v-for="depiction in depictions"
            :key="depiction.id"
            class="light-table-sources__thumb"
            :class="{
              'light-table-sources__thumb--placed': isPlaced(depiction)
            }"
            :title="
              isPlaced(depiction)
                ? 'Already on the light table'
                : 'Click or drag to add'
            "
            draggable="true"
            @click="emitAdd([depiction])"
            @dragstart="(e) => onDragStart(e, depiction)"
          >
            <img
              :src="depiction.image.alternatives.thumb.image_file_url"
              :alt="depiction.caption || `Depiction ${depiction.id}`"
              draggable="false"
            />
          </li>
        </ul>
      </template>
    </template>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { DEPICTION } from '@/constants'
import { DRAG_TYPE } from '../../constants'
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const MAX_DEPICTIONS = 500

const props = defineProps({
  placedKeys: {
    type: Set,
    required: true
  }
})

const emit = defineEmits(['add'])

const otu = ref(null)
const depictions = ref([])
const isLoading = ref(false)

const pendingDepictions = computed(() =>
  depictions.value.filter((d) => !isPlaced(d))
)

function isPlaced(depiction) {
  return props.placedKeys.has(`${DEPICTION}:${depiction.id}`)
}

function selectOtu(item) {
  otu.value = item
  depictions.value = []
  isLoading.value = true

  Depiction.filter({
    otu_id: [item.id],
    otu_scope: ['all'],
    per: MAX_DEPICTIONS,
    extend: ['depiction_object']
  })
    .then(({ body }) => {
      depictions.value = body
    })
    .catch(() => {})
    .finally(() => {
      isLoading.value = false
    })
}

function clear() {
  otu.value = null
  depictions.value = []
}

function payload(list) {
  return {
    objectType: DEPICTION,
    objects: list
  }
}

function emitAdd(list) {
  emit('add', payload(list))
}

function onDragStart(event, depiction) {
  event.dataTransfer.setData(DRAG_TYPE, JSON.stringify(payload([depiction])))
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
