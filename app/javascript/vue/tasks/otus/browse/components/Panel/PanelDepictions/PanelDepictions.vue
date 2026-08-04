<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
    :empty="!depictions.length"
  >
    <div
      v-if="depictions.length"
      class="depictions-gallery"
    >
      <ImageViewer
        v-for="item in visibleDepictions"
        :key="item.id"
        :depiction="item"
        thumb-size="medium"
        edit
      >
        <template #default="{ src, hasCrop }">
          <div class="depictions-gallery__tile">
            <img
              class="depictions-gallery__image"
              :src="src"
              :srcset="hasCrop ? undefined : srcsetFor(item)"
              :sizes="TILE_SIZES"
              :alt="plainText(item.figure_label) || 'Depiction'"
              loading="lazy"
              decoding="async"
            />
          </div>
        </template>

        <template
          v-if="item.figure_label"
          #thumbfooter
        >
          <div
            class="depictions-gallery__label"
            :title="plainText(item.caption || item.figure_label)"
            v-html="item.figure_label"
          />
        </template>
      </ImageViewer>

      <button
        v-if="isCollapsed"
        type="button"
        class="depictions-gallery__more"
        :title="`Show ${hiddenCount} more images`"
        @click="isExpanded = true"
      >
        <span
          class="depictions-gallery__collage"
          :class="`depictions-gallery__collage--${collageDepictions.length}`"
        >
          <img
            v-for="item in collageDepictions"
            :key="item.id"
            :src="thumbUrlFor(item)"
            alt=""
            loading="lazy"
            decoding="async"
          />
        </span>
        <span class="depictions-gallery__more-label">+{{ hiddenCount }}</span>
      </button>
    </div>
    <div v-else>No images available</div>

    <VBtn
      v-if="isExpanded"
      class="separate-top"
      color="primary"
      variant="tonal"
      @click="isExpanded = false"
    >
      Show less
    </VBtn>
  </PanelLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { sanitizeHtml, imageSVGViewBox } from '@/helpers'
import PanelLayout from '../PanelLayout.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Depictions'
  }
})

const TILE_SIZES = '(min-width: 1200px) 180px, 150px'

const PREVIEW_TILES = 12
const COLLAGE_TILES = 4
const THUMB_SIZE = 100

const depictions = ref([])
const isLoading = ref(false)
const isExpanded = ref(false)

const isCollapsed = computed(
  () => !isExpanded.value && depictions.value.length > PREVIEW_TILES
)

const visibleDepictions = computed(() =>
  isCollapsed.value
    ? depictions.value.slice(0, PREVIEW_TILES - 1)
    : depictions.value
)

const hiddenCount = computed(
  () => depictions.value.length - visibleDepictions.value.length
)

const collageDepictions = computed(() =>
  depictions.value.slice(PREVIEW_TILES - 1, PREVIEW_TILES - 1 + COLLAGE_TILES)
)

function srcsetFor(depiction) {
  const alternatives = depiction.image?.alternatives

  if (!alternatives) return undefined

  return [alternatives.thumb, alternatives.medium]
    .filter((alternative, index, all) =>
      alternative
        ? index === 0 || alternative.width > all[index - 1].width
        : false
    )
    .map(({ image_file_url, width }) => `${image_file_url} ${width}w`)
    .join(', ')
}

function plainText(value) {
  return value ? sanitizeHtml(value) : ''
}

function thumbUrlFor(depiction) {
  const image = depiction.image

  return depiction.svg_view_box
    ? imageSVGViewBox(image.id, depiction.svg_view_box, THUMB_SIZE, THUMB_SIZE)
    : image.alternatives.thumb.image_file_url
}

async function loadDepictions(otuId) {
  isLoading.value = true

  try {
    const { body } = await Depiction.filter({
      otu_id: otuId,
      otu_scope: ['all'],
      per: 500
    })

    depictions.value = body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    const otuIds = newVal.map((o) => o.id)

    if (otuIds.length > 0) {
      loadDepictions(otuIds)
    }
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
.depictions-gallery {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 0.5rem;

  :deep(.depiction-thumb-container) {
    margin: 0;
  }
}

.depictions-gallery__tile {
  display: grid;
  place-items: center;
  aspect-ratio: 1;
  overflow: hidden;
  border-radius: var(--border-radius-small);
  background-color: var(--bg-muted);
}

.depictions-gallery__image {
  max-width: 100%;
  max-height: 100%;
  width: auto;
  height: auto;
}

.depictions-gallery__more {
  --depictions-scrim: rgb(0 0 0 / 0.55);

  position: relative;
  display: block;
  aspect-ratio: 1;
  padding: 0;
  overflow: hidden;
  border: 0;
  border-radius: var(--border-radius-small);
  background-color: var(--bg-muted);
  cursor: pointer;

  &:hover .depictions-gallery__more-label {
    background-color: rgb(0 0 0 / 0.68);
  }
}

.depictions-gallery__collage {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-template-rows: repeat(2, 1fr);
  width: 100%;
  height: 100%;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
}

.depictions-gallery__collage--2 {
  grid-template-rows: 1fr;
}

.depictions-gallery__collage--3 img:first-child {
  grid-row: span 2;
}

.depictions-gallery__more-label {
  position: absolute;
  inset: 0;
  display: grid;
  place-items: center;
  background-color: var(--depictions-scrim);
  color: #ffffff;
  font-size: 1.5rem;
  font-weight: 600;
  transition: background-color 0.15s ease;
}

.depictions-gallery__label {
  overflow: hidden;
  padding-top: 0.25rem;
  color: var(--text-muted-color);
  font-size: var(--font-size-xs);
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
