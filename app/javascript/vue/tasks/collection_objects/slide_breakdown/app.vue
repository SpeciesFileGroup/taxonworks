<template>
  <div>
    <spinner-component
      :full-screen="true"
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"/>
    <h1>Grid digitizer</h1>
    <nav-bar/>
    <template v-if="image">
      <div class="horizontal-left-content align-start">
        <div
          class="position-relative"
          style="width: 50%;">
          <quick-grid
            v-if="!disabledPanel"
            :width="image.width"
            :height="image.height"
            :vertical-lines="vlines"
            :horizontal-lines="hlines"
            @onLines="setGrid"
            @grid="setGrid"/>
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
          <template
            v-for="(hline, index) in hlines"
            v-if="index > 0 && index < hlines.length-1 && !disabledPanel">
            <remove-line
              :style="{
                top: `${removeButtonPosition(hline, style.viewer.marginTop)}px`,
                right: 0,
                transform: 'translateY(-50%)'
              }"
              v-model="hlines"
              :position="index"
            />
          </template>
          <template
            v-for="(vline, index) in vlines"
            v-if="index > 0 && index < vlines.length-1 && !disabledPanel">
            <remove-line
              :style="{ 
                left: `${removeButtonPosition(vline, style.viewer.marginLeft)}px`,
                transform: 'translateX(-50%)',
                top: `${removeButtonPosition(hlines[hlines.length-1], style.viewer.marginBottom)}px`
              }"
              v-model="vlines"
              :position="index"
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
              :metadata-assignment="metadata"
              :file-image="fileImage"
              :locked="sledImage.summary.length > 0"
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
                v-if="disabledPanel && view == 'Assign'"
                :show-legend="false"
                :show-spinner="false"/>
              <component
                :is="componentSelected"/>
            </div>
            <summary-component
              v-if="view != 'Review'"
              @update="createSled"
              @updateNew="createSled(true)"
              @updateNext="createSled(true, $event)"
              class="full_width margin-medium-left"/>
          </div>
        </div>
      </div>
    </template>
    <upload-image
      class="full_width margin-large-top"
      v-else
      @created="createImage($event.id)"/>
  </div>
</template>

<script>

import Sled from '@sfgrp/sled'
import ScaleValue from 'helpers/scale'
import { GetImage, GetSledImage, GetUserPreferences, UpdateUserPreferences } from './request/resource'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

import AddLine from './components/AddLine'
import RemoveLine from './components/grid/RemoveLine'
import SwitchComponent from 'components/switch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review'
import OverviewMetadataComponent from './components/Overview'
import SummaryComponent from './components/Summary'
import SpinnerComponent from 'components/spinner'
import QuickGrid from './components/grid/Quick'
import NavBar from './components/NavBar'
import SetParam from 'helpers/setParam.js'

export default {
  components: {
    Sled,
    AddLine,
    RemoveLine,
    SwitchComponent,
    AssignComponent,
    ReviewComponent,
    OverviewMetadataComponent,
    UploadImage,
    SummaryComponent,
    SpinnerComponent,
    QuickGrid,
    NavBar
  },
  computed: {
    disabledPanel () {
      let sled = this.$store.getters[GetterNames.GetSledImage]
      return sled && sled['summary'] && sled.summary.length > 0
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
    },
    identifier () {
      return this.$store.getters[GetterNames.GetIdentifier]
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
      isSaving: false,
      tabs: ['Assign', 'Overview metadata', 'Review'],
      view: 'Assign',
      configString: 'tasks::griddigitize::quickgrid',
      preferences: undefined,
      metadata: {
        annotated_specimen: 'Annotated specimen',
        collecting_event_labels: 'Collecting event labels',
        curator_metadata: 'Curator metadata',
        determination_labels: 'Determination labels',
        identifier: 'Identifier',
        image_registration: 'Image registration',
        other_labels: 'Other labels',
        labels: 'Labels',
        specimen: 'Specimen',
        stage: 'Stage'
      },
      style: {
        viewer: {
          position: 'relative',
          marginLeft: '30px',
          marginRight: '30px',
          marginTop: '50px',
          marginBottom: '60px'
        }
      }
    }
  },
  watch: {
    identifier: {
      handler(newVal) {
        this.$refs.sled.cells = this.setIdentifiers(this.sledImage.metadata)
      },
      deep: true
    },
    sledImage: {
      handler(newVal, oldVal) {
        this.$refs.sled.cells = this.setIdentifiers(newVal.metadata, newVal.summary)
      },
      deep: true
    }
  },
  mounted () {
    let urlParams = new URLSearchParams(window.location.search)
    let imageId = urlParams.get('image_id')
    let sledId = urlParams.get('sled_image_id')
    if(imageId && /^\d+$/.test(imageId)) {
      this.loadImage(imageId).then(response => {
        this.loadSled(response.sled_image_id)
      })
    }
    if(sledId && /^\d+$/.test(sledId)) {
      GetSledImage(sledId).then(sledResponse => {
        this.loadImage(sledResponse.body.image_id).then(response => {
          if(sledResponse.body.metadata.length) {
            this.sledImage = sledResponse.body
          }
          else {
            sledResponse.body.metadata = this.sledImage.metadata
            this.sledImage = sledResponse.body
          }
          if(sledResponse.body.metadata.length) {
            this.setLines(this.setIdentifiers(sledResponse.body.metadata, sledResponse.body.summary))
            this.$nextTick(() => {
              this.$refs.sled.cells = sledResponse.body.metadata
            })
          }

          this.isLoading = false
        }, () => {
          this.isLoading = false
        })
      })
    }
  },
  methods: {
    loadPreferences () {
      GetUserPreferences().then(response => {
        let that = this
        this.preferences = response.body
        if (this.sledImage.summary.length) return
        let sizes = this.preferences.layout[this.configString]
        if(sizes) {
          this.vlines = sizes.columns.map(column => column * this.image.width),
          this.hlines = sizes.rows.map(row => row * this.image.height)
          if(sizes.metadata)
            this.$nextTick(()=> {
              that.$refs.sled.cells = that.$refs.sled.cells.map((cell, index) => { cell.metadata = sizes.metadata[index] == 'null' ? null : sizes.metadata[index]; return cell })
            })
        }
      })
    },
    savePreferences () {
      let columns = this.vlines.map(line => { return ScaleValue(line, 0, this.image.width, 0, 1) })
      let rows = this.hlines.map(line => { return ScaleValue(line, 0, this.image.height, 0, 1) })
      let metadata = this.$refs.sled.cells.map(cell => { return `${cell.metadata}` })

      UpdateUserPreferences(this.preferences.id, { [this.configString]: { columns: columns, rows: rows, metadata: metadata } }).then(response => {
        this.preferences = response.body
      })
    },
    createImage(imageId) {
      this.loadImage(imageId).then(response => {
        this.loadSled(response.sled_image_id)
      })
    },
    processCells (cells) {
      if (this.sledImage.summary.length) return
      this.sledImage.metadata = cells
    },
    createSled (load = false, id = undefined) {
      this.isSaving = true
      this.savePreferences()
      this.$store.dispatch(ActionNames.UpdateSled).then(() => {
        this.isSaving = false
        if (load) {
          SetParam('/tasks/collection_objects/grid_digitize/index', 'sled_image_id', id)
          this.$store.dispatch(ActionNames.ResetStore)
        }
      }, () => {
        this.isSaving = false
      })
    },
    setGrid (grid) {
      if (this.sledImage.summary.length) return
      this.$refs.sled.cells.forEach(item => {
        item.metadata = null
      })
      this.vlines = grid.vlines
      this.hlines = grid.hlines
    },
    loadSled (sledId) {
      return new Promise((resolve, reject) => {
        GetSledImage(sledId).then(response => {
          SetParam('/tasks/collection_objects/grid_digitize/index', 'sled_image_id', sledId)
          if(response.body.metadata.length) {
            this.sledImage = response.body
          }
          else {
            response.body.metadata = this.sledImage.metadata
            this.sledImage = response.body
          }
          if(response.body.metadata.length) {
            let that = this
            this.setLines(this.setIdentifiers(response.body.metadata, response.body.summary))
            this.$nextTick(() => {
              that.$refs.sled.cells = response.body.metadata
            })
          }

          this.isLoading = false
          resolve(response)
        }, (resolve) => {
          reject(resolve)
        })
      })
    },
    loadImage (imageId) {
      return new Promise((resolve, reject) => {
        this.isLoading = true
        GetImage(imageId).then(response => {
          
          let that = this
          let ajaxRequest = new XMLHttpRequest()
          
          this.image = response.body
          ajaxRequest.open('GET', response.body.image_display_url)
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
                this.isLoading = false
                this.loadPreferences()
                resolve(response.body)
              }

              image.src = dataUrl
            };
            fr.readAsDataURL(blob)
          };
          ajaxRequest.send()
        }, () => {
          this.isLoading = false
          reject()
        })
      })
    },
    getPosition (line, next) {
      return (next ? line + ((next - line ) / 2) : line)
    },
    getButtonPosition (lines, index, margin) {
      return this.getPosition(lines[index], lines[index+1]) / this.scale + parseInt(margin)
    },
    removeButtonPosition (line, margin) {
      return line / this.scale + parseInt(margin)
    },
    setLines (cells) {
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
    },
    convertToMatrix (metadata) {
      let i = []

      metadata.forEach(cell => {
        let r = cell.row
        let c = cell.column
        if(!i[r]) { i[r] = [] }
        i[r][c] = cell.metadata != null ? 0 : 1
      })
      return i
    },
    metadataCount (matrix, c, r) {
      let inc = 0
      for(let i = 0; i <= c; i++) {
        for(let j = 0; j <= matrix.length-1; j++) {
          if(i == c && j > r) break
          else {
            if(matrix[j][i] == 0) {
              inc++
            }
          }
        }
      }
      return inc
    },
    setIdentifiers (metadata, summary = undefined) {
      if(!this.sledImage.step_identifier_on) return metadata.map(cell => { cell.textfield = undefined; return cell })
      if(summary && summary.length) {
        return metadata.map(cell => {
          cell.textfield = summary[cell.row][cell.column].identifier
          return cell
        })
      }
      else {
        if (this.identifier.namespace_id && this.identifier.identifier) {
          let identifier = Number(this.identifier.identifier)
          let matrix = this.convertToMatrix(metadata)
          let decrease = 0

          return metadata.map((cell) => {
            let c = cell.column
            let r = cell.row
            let inc = r + c + identifier

            if (cell.metadata) {
              decrease++
              cell.textfield = undefined
            }
            else {
              cell.textfield = (
                this.sledImage.step_identifier_on == 'row' ?
                `${this.identifier.label} ${(r * (this.vlines.length-2)) + inc - decrease}` :
                `${this.identifier.label} ${(c * (this.hlines.length-2)) + inc - this.metadataCount(matrix, c, r)}`
              )
            }
            return cell
          })
        }
        else {
          return metadata.map((cell) => {
            cell.textfield = undefined
            return cell
          })
        }
      }
    }
  }
}
</script>
