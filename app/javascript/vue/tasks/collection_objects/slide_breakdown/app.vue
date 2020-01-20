<template>
  <div>
    <h1>Slide tray breakdown</h1>
    <template v-if="imageId">
      <div class="horizontal-left-content align-start">
        
        <div
          class="position-relative"
          style="width: 50%;">
          <template
            v-for="(hline, index) in hlines"
            v-if="index < hlines.length-1">
            <add-line
              :style="{ 
                top: `${getButtonPosition(hlines, index, style.viewer.marginTop)}px`,
                transform: 'translateY(-50%)'
              }"
              :position="getPosition(hline, hlines[index+1])"
              v-model="hlines"
            />
          </template>
          <template
            v-for="(vline, index) in vlines"
            v-if="index < vlines.length-1">
            <add-line
              :style="{ 
                left: `${getButtonPosition(vlines, index, style.viewer.marginLeft)}px`,
                transform: 'translateX(-50%)',
                top: `10px`
              }"
              :position="getPosition(vline, vlines[index+1])"
              v-model="vlines"
            />
          </template>
          <div :style="style.viewer">
            <sled 
              ref="sled"
              :vertical-lines="vlines"
              :horizontal-lines="hlines"
              :image-width="image.width"
              :image-height="image.height"
              :line-weight="lineWeight"
              :autosize="true"
              :file-image="fileImage"
              @onComputeCells="processCells"/>
          </div>
        </div>
        <div
          class="margin-medium-left"
          style="width: 50%;">
          <switch-component
            v-model="view"
            :options="tabs"/>
          <component
            class="margin-large-top"
            :is="componentSelected"/>
        </div>
      </div>
    </template>
    <upload-image
      class="full_width margin-large-top"
      v-else
      @created="imageId = $event.id"/>
  </div>
</template>

<script>

import Sled from '@sfgrp/sled'
import { GetImage } from './request/resource'
import AddLine from './components/AddLine'
import SwitchComponent from 'components/switch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review'
import OverviewMetadataComponent from './components/Overview'

export default {
  components: {
    Sled,
    AddLine,
    SwitchComponent,
    AssignComponent,
    ReviewComponent,
    OverviewMetadataComponent,
    UploadImage
  },
  computed: {
    componentSelected () {
      return `${this.view.toPascalCase().replace(' ', '')}Component`
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
      imageId: undefined,
      cells: [],
      selectedCells: [],
      tabs: ['Assign', 'Overview metadata', 'Review'],
      view: 'Assign',
      style: {
        viewer: {
          position: 'relative',
          marginLeft: '30px',
          marginTop: '50px'
        }
      },
    }
  },
  watch: {
    imageId: {
      handler(newVal) {
        if (/^\d+$/.test(newVal)) {
          this.loadImage(newVal)
        }
      },
      immediate: true
    }
  },
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)
    this.imageId = urlParams.get('image_id')
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
      return (next ? line + ((next - line ) / 2) : line)
    },
    scaleForScreen () {
      let element = this.$refs.sled.$el.getBoundingClientRect()
      let scaleHeight = element.height < this.image.height && element.height > 0 ? this.image.height / element.height : 1
      let scaleWidth = element.width < this.image.width && element.width > 0 ? this.image.width / element.width : 1
      return scaleHeight > scaleWidth ? scaleHeight : scaleWidth
    },
    getButtonPosition(lines, index, margin) {
      return this.getPosition(lines[index], lines[index+1]) / this.scaleForScreen() + parseInt(margin)
    }
  }
}
</script>
