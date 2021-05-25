<template>
  <div
    class="observation-cell padding-small">
    <div
      v-for="depiction in depictions"
      :key="depiction.id">
      <tippy-component
        animation="scale"
        placement="bottom"
        size="small"
        arrow-size="small"
        inertia
        arrow
        :trigger="!!depiction.source_cached
          ? 'mouseenter focus'
          : 'manual'"
        :content="depiction.source_cached">
        <template slot="trigger">
          <image-viewer
            :depiction="depiction"
          >
            <img :src="depiction.image.alternatives.medium.image_file_url">
            <div
              class="panel content full_width margin-small-right"
              slot="infoColumn">
              <h3>Image matrix</h3>
              <ul class="no_bullets">
                <li>Column: <b>{{ descriptor }}</b></li>
                <li>Row:
                  <cell-link
                    :label="object.object_tag"
                    :row-object="object"
                  />
                </li>
              </ul>
            </div>
          </image-viewer>
        </template>
      </tippy-component>
    </div>
  </div>
</template>

<script>

import { TippyComponent } from 'vue-tippy'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import CellLink from '../CellLink'

export default {
  components: {
    ImageViewer,
    TippyComponent,
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
