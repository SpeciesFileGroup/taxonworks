<template>
  <div class="observation-cell padding-small">
    <div
      v-for="depiction in depictions"
      :key="depiction.id"
    >
      <VTooltip
        :disabled="!depiction.source_cached"
        :content="depiction.source_cached"
      >
        <ImageViewer :depiction="depiction">
          <div class="matrix-thumb-image">
            <img
              class="img-thumb"
              :src="depiction.image.alternatives.thumb.image_file_url"
            />
          </div>
          <template #infoColumn>
            <div class="panel content full_width margin-small-right">
              <h3>Image matrix</h3>
              <ul class="no_bullets">
                <li>
                  Column: <b>{{ descriptor }}</b>
                </li>
                <li>
                  Row:
                  <cell-link
                    :label="object.object_tag"
                    :row-object="object"
                  />
                </li>
              </ul>
            </div>
          </template>
        </ImageViewer>
      </VTooltip>
    </div>
  </div>
</template>

<script>
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import CellLink from '../CellLink'

export default {
  components: {
    ImageViewer,
    VTooltip,
    CellLink
  },

  props: {
    depictions: {
      type: Array,
      default: () => []
    },

    object: {
      type: Object,
      required: true
    },

    descriptor: {
      type: String,
      required: true
    }
  }
}
</script>

<style scoped>
.img-thumb {
  object-fit: cover;
  width: auto;
  height: 100%;
  background-color: white;
}
</style>
