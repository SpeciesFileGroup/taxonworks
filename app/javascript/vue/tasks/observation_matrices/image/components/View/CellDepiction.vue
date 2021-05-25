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
                <li>Row: <a
                  v-html="object.object_tag"
                  :href="browseLink(object)"/>
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
import { RouteNames } from 'routes/routes'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
const BROWSE_LINK = {
  CollectionObject: id => `${RouteNames.BrowseCollectionObject}?collection_object_id=${id}`,
  Otu: id => `${RouteNames.BrowseOtu}?otu_id=${id}`,
  TaxonName: id => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
}

export default {
  components: {
    ImageViewer,
    TippyComponent
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
  },
  methods: {
    browseLink (object) {
      const objectClass = {
        otu_id: 'Otu',
        collection_object_id: 'CollectionObject',
        taxon_name_id: 'TaxonName'
      }

      const [property, klass] = Object.entries(objectClass).find(([key, value]) => object[key])

      return BROWSE_LINK[klass](object[property])
    }
  }
}
</script>