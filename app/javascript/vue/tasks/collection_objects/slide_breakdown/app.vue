<template>
  <div>
    <h1>Slide tray breakdown</h1>
    <div class="horizontal-left-content align-start">
      <div
        class="sled-panel"
        style="width: 50%;">
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
            :style="{ left: `${getPosition(vline, vlines[index+1]) / scaleForScreen}px`, top: `10px` }"
            :position="getPosition(vline, vlines[index+1])"
            v-model="vlines"
          />
        </template>
        <div  class="sled-viewer">
          <sled 
            :vertical-lines="vlines"
            :horizontal-lines="hlines"
            :image-width="image.width"
            :image-height="image.height"
            :line-weight="lineWeight"
            :scale="scaleForScreen"
            :file-image="fileImage"
            @onComputeCells="processCells"/>
        </div>
      </div>
      <div style="width: 50%;">
        <switch-component
          v-model="view"
          :options="tabs"/>
        <assign-component class="margin-large-top"/>
      </div>
    </div>
  </div>
</template>

<script>

import Sled from '@sfgrp/sled'
import { GetImage } from './request/resource'
import AddLine from './components/AddLine'
import SwitchComponent from 'components/switch'
import AssignComponent from './components/Assign/Main'

export default {
  components: {
    Sled,
    AddLine,
    SwitchComponent,
    AssignComponent
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
      vlines: [],
      hlines: [],
      image: {
        width: 0,
        height: 0
      },
      lineWeight: 2,
      scale: 1,
      fileImage: undefined,
      isLoading: false,
      buttonSize: 20,
      imageId: undefined,
      cells: [],
      selectedCells: [],
      tabs: ['assign', 'overview metadata', 'review'],
      view: undefined
    }
  },
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)
    this.imageId = urlParams.get('image_id')

    if (/^\d+$/.test(this.imageId)) {
      this.loadImage(this.imageId)
    }
  },
  methods: {
    processCells(cells) {
      this.cells = cells
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
    },
  }
}
</script>
<style scoped>
  .sled-panel {
    position: relative;
  }
  .sled-viewer {
    position: relative;
    margin-left: 30px;
    margin-top: 50px;
  }
</style>