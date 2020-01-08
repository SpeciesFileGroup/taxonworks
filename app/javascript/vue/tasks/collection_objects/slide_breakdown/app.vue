<template>
  <div>
    <h1>Slide tray breakdown</h1>
    <div class="sled-panel">
      <template
        v-for="(hline, index) in hlines"
        v-if="index < hlines.length-1">
        <add-line
          :style="{ top: `${getPosition(hline, hlines[index+1]) / scaleForScreen}px` }"
          :position="getPosition(hline, hlines[index+1])"
          v-model="hlines"
        />
      </template>
      <template
        v-for="(vline, index) in vlines"
        v-if="index < vlines.length-1">
        <add-line
          :style="{ left: `${getPosition(vline, vlines[index+1]) / scaleForScreen}px`, top: `-30px` }"
          :position="getPosition(vline, vlines[index+1])"
          v-model="vlines"
        />
      </template>
      <sled 
        class="sled-viewer"
        :vertical-lines="vlines"
        :horizontal-lines="hlines"
        :image-width="image.width"
        :image-height="image.height"
        :line-weight="lineWeight"
        :scale="scaleForScreen"
        :file-image="fileImage"
        @onComputeCells="processCells">
      </sled>
    </div>
  </div>
</template>

<script>

import Sled from '@sfgrp/sled'
import { GetImage } from './request/resource'
import AddLine from './components/AddLine'

export default {
  components: {
    Sled,
    AddLine
  },
  computed: {
    scaleForScreen () {
      let scaleHeight = window.outerHeight < this.image.height ? this.image.height / window.outerHeight : 1
      let scaleWidth = window.outerWidth < this.image.width ? this.image.width / window.outerWidth : 1
      return scaleHeight > scaleWidth ? scaleHeight : scaleWidth
    }
  },
  data () {
    return {
      vlines: [30,50,90],
      hlines: [30,80,70, 90,400],
      image: {
        width: 0,
        height: 0
      },
      lineWeight: 2,
      scale: 1,
      fileImage: undefined,
      isLoading: false,
      buttonSize: 20
    }
  },
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)
    let imageId = urlParams.get('image_id')

    if (/^\d+$/.test(imageId)) {
      this.loadImage(imageId)
    }
  },
  methods: {
    processCells(cells) {
      console.log(cells)
    },
    loadImage(imageId) {
      GetImage(imageId).then(response => {
        
        let that = this
        let ajaxRequest = new XMLHttpRequest()
        
        ajaxRequest.open('GET', response.body.image_file_url)
        ajaxRequest.responseType = 'blob'
        ajaxRequest.onload = () => {
          let blob = ajaxRequest.response
          let fr = new FileReader()

          fr.onloadend = () => {
            let dataUrl = fr.result
            let image = new Image
              
            image.onload = () => {
              that.image.width = image.width
              that.image.height = image.height
              that.fileImage = dataUrl
              that.vlines = [0, that.image.width]
              that.hlines = [0 ,that.image.height]
            }

            image.src = dataUrl
          };
          fr.readAsDataURL(blob)
        };
        ajaxRequest.send()
      })
    },
    getPosition (line, next) {
      return (next ? line + ((next - line) / 2) : line) + this.buttonSize
    }
  }
}
</script>
<style scoped>
  .sled-panel {
    position: relative;
  }
  .sled-viewer {
    margin-left: 30px;
    margin-top: 50px;
  }
</style>