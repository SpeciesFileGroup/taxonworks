<template>
  <div>
    <spinner-component
      :full-screen="true"
      v-if="isLoading"/>
    <h1>Slide tray breakdown</h1>
    <template v-if="image">
      <div class="horizontal-left-content align-start">
        
        <div
          class="position-relative"
          style="width: 50%;">
          <template
            v-for="(hline, index) in hlines"
            v-if="index < hlines.length-1 && !disabledPanel">
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
            v-if="index < vlines.length-1 && !disabledPanel">
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
              :metadata-assignment="{ test: 'Test label' }"
              :file-image="fileImage"
              @resize="scale = $event.scale"
              @onComputeCells="processCells"/>
          </div>
        </div>
        <div
          class="margin-medium-left"
          style="width: 50%;">
          <switch-component
            v-model="view"
            :options="tabs"/>
          <div class="flex-separate margin-large-top">
            <div class="full_width">
              <spinner-component
                v-if="disabledPanel"
                :show-legend="false"
                :show-spinner="false"/>
              <component
                :is="componentSelected"/>
            </div>
            <summary-component
              @update="createSled"
              class="full_width margin-medium-left"/>
          </div>
        </div>
      </div>
    </template>
    <upload-image
      class="full_width margin-large-top"
      v-else
      @created="loadImage($event.id)"/>
  </div>
</template>

<script>

import Sled from '@sfgrp/sled'
import { GetImage, GetSledImage } from './request/resource'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

import AddLine from './components/AddLine'
import SwitchComponent from 'components/switch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review'
import OverviewMetadataComponent from './components/Overview'
import SummaryComponent from './components/Summary'
import SpinnerComponent from 'components/spinner'

export default {
  components: {
    Sled,
    AddLine,
    SwitchComponent,
    AssignComponent,
    ReviewComponent,
    OverviewMetadataComponent,
    UploadImage,
    SummaryComponent,
    SpinnerComponent
  },
  computed: {
    disabledPanel () {
      let sled = this.$store.getters[GetterNames.GetSledImage]
      return sled && sled['summary'] && sled.summary.length
    },
    componentSelected () {
      return `${this.view.toPascalCase().replace(' ', '')}Component`
    },
    sledImage: {
      get () {
        return this.$store.getters[GetterNames.GetSledImage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSledImage, value)
      }
    },
    image: {
      get () {
        return this.$store.getters[GetterNames.GetImage]
      },
      set (value) {
        this.$store.commit(MutationNames.SetImage, value)
      }
    }
  },
  data () {
    return {
      vlines: [],
      hlines: [],
      lineWeight: 2,
      scale: 1,
      fileImage: undefined,
      isLoading: false,
      cells: [],
      tabs: ['Assign', 'Overview metadata', 'Review'],
      view: 'Assign',
      scale: 1,
      style: {
        viewer: {
          position: 'relative',
          marginLeft: '30px',
          marginTop: '50px'
        }
      }
    }
  },
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)
    let imageId = urlParams.get('image_id')
    if(imageId && /^\d+$/.test(imageId)) {
      this.loadImage(imageId)
    }
  },
  methods: {
    processCells(cells) {
      this.sledImage.metadata = cells
    },
    createSled () {
      this.$store.dispatch(ActionNames.UpdateSled)
    },
    loadImage(imageId) {
      this.isLoading = true
      GetImage(imageId).then(response => {
        
        let that = this
        let ajaxRequest = new XMLHttpRequest()
        
        this.image = response.body
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

              GetSledImage(response.body.sled_image_id).then(response => {
                this.sledImage = response.body
                //cells
                if(response.body.metadata.length) {
                  this.setLines(response.body.metadata)
                  this.$refs.sled.cells = response.body.metadata
                }
              })
              this.isLoading = false
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
    getButtonPosition(lines, index, margin) {
      return this.getPosition(lines[index], lines[index+1]) / this.scale + parseInt(margin)
    },
    setLines(cells) {
      let xlines = []
      let ylines = []
      cells.forEach(cell => {
        xlines.push(cell.lowerCorner.x)
        ylines.push(cell.lowerCorner.y)
        xlines.push(cell.upperCorner.x)
        ylines.push(cell.upperCorner.y)
      })
      this.vlines = [...new Set(xlines)]
      this.hlines = [...new Set(ylines)]
    }
  }
}
</script>
