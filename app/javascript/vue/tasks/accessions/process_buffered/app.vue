<template>
  <div>
    <h1>Buffered data</h1>
    <div class="horizontal-left-content align-start">
      <div>
        <h2>Collection object</h2>
        <nav-collection-objects
          :co-objects="nearbyCO"/>
        <hr>
        <collection-object-container/>
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
        </div>
      </div>

      <div>
        <h2>Collecting event</h2>
        <collecting-event
          :collection-object="collectionObject"/>
      </div>
    </div>
  </div>
</template>

<script>

import CollectingEvent from './components/collectingEvent'
import DepictionsContainer from './components/depictionsContainer'
import ImageEditor from './components/imageEditor'
import CanvasContainer from './components/canvasContainer'
import NavCollectionObjects from './components/navCollectionObjects'
import CollectionObjectContainer from './components/collectionObject'

import { GetDepictionByCOId, GetCollectionObject, GetNearbyCOFromDepictionSqedId } from './request/resource'

export default {
  components: {
    CanvasContainer,
    CollectingEvent,
    DepictionsContainer,
    ImageEditor,
    NavCollectionObjects,
    CollectionObjectContainer
  },
  data () {
    return {
      collectionObject: undefined,
      depictions: undefined,
      image: undefined,
      canvasImage: undefined,
      nearbyCO: {},
      imagePosition: []
    }
  },
  mounted () {
    this.checkForParams()
  },
  watch: {
    depictions (newVal) {
      const sqed = this.depictions.find(item => {
        return item.hasOwnProperty('sqed_depiction')
      })
      if (sqed) {
        GetNearbyCOFromDepictionSqedId(sqed.sqed_depiction.id).then(response => {
          this.nearbyCO = response.body
        })
      }
    }
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