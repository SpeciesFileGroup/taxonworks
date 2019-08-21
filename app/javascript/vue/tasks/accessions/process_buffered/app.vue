<template>
  <div>
    <h1>Buffered data</h1>
    <div class="flexbox">
      <depictions-container
        :depictions="depictions"
        @selectedImage="image=$event"/>
      <div>
        <image-editor
          :image="image"
          @imagePosition="setImageValues"/>
        <canvas-container :image="canvasImage"/>
      </div>
      <collecting-event
        :collection-object="collectionObject"/>
    </div>
  </div>
</template>

<script>

import CollectingEvent from './components/collectingEvent'
import DepictionsContainer from './components/depictionsContainer'
import ImageEditor from './components/imageEditor'
import CanvasContainer from './components/canvasContainer'

import { GetDepictionByCOId, GetCollectionObject } from './request/resource'

export default {
  components: {
    CanvasContainer,
    CollectingEvent,
    DepictionsContainer,
    ImageEditor
  },
  data () {
    return {
      collectionObject: undefined,
      depictions: undefined,
      image: undefined,
      canvasImage: undefined,
      imagePosition: []
    }
  },
  mounted () {
    this.checkForParams()
  },
  methods: {
    checkForParams () {
      const urlParams = new URLSearchParams(window.location.search)
      const COId = urlParams.get('collection_object_id')

      if (/^\d+$/.test(COId)) {
        GetDepictionByCOId(COId).then(response => {
          this.depictions = response.body
        })
        GetCollectionObject(COId).then(response => {
          this.collectionObject = response.body
        })
      }
    },
    setImageValues (values) {
      this.canvasImage = {
        src: this.image.large_image,
        x: values.x,
        y: values.y,
        width: values.width,
        height: values.height
      }
    }
  }
}
</script>