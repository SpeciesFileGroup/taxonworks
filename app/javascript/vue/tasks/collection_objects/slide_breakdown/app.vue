<template>
  <div>
    <spinner-component
      :full-screen="true"
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"
    />
    <nav-bar />
    <template v-if="image">
      <div class="horizontal-left-content align-start">
        <div
          class="position-relative"
          style="width: 50%"
        >
          <quick-grid
            v-if="!disabledPanel"
            :width="image.width"
            :height="image.height"
            :vertical-lines="vlines"
            :horizontal-lines="hlines"
            @onLines="setGrid"
            @grid="setGrid"
          />
          <template v-for="(hline, index) in hlines">
            <VBtn
              v-if="index < hlines.length - 1 && !disabledPanel"
              color="primary"
              class="btn-line"
              :style="{
                top: `${getButtonPosition(
                  hlines,
                  index,
                  style.viewer.marginTop
                )}px`,
                left: vlines[0] / scale + 'px',
                transform: 'translateY(-50%)'
              }"
              @click="hlines.push(getPosition(hline, hlines[index + 1]))"
            >
              +
            </VBtn>
          </template>
          <template v-for="(vline, index) in vlines">
            <VBtn
              v-if="index < vlines.length - 1 && !disabledPanel"
              color="primary"
              class="btn-line"
              :style="{
                left: `${getButtonPosition(
                  vlines,
                  index,
                  style.viewer.marginLeft
                )}px`,
                top: hlines[0] / scale + 'px',
                transform: 'translateX(-50%)'
              }"
              @click="vlines.push(getPosition(vline, vlines[index + 1]))"
            >
              +
            </VBtn>
          </template>
          <template v-for="(hline, index) in hlines">
            <VBtn
              v-if="index > 0 && index < hlines.length - 1 && !disabledPanel"
              color="primary"
              class="btn-line"
              :style="{
                top: `${removeButtonPosition(hline, style.viewer.marginTop)}px`,
                left:
                  removeButtonPosition(
                    vlines.at(-1),
                    style.viewer.marginRight
                  ) + 'px',
                transform: 'translate(50%, -50%)'
              }"
              @click="hlines.splice(index, 1)"
            >
              -
            </VBtn>
          </template>
          <template v-for="(vline, index) in vlines">
            <VBtn
              v-if="index > 0 && index < vlines.length - 1 && !disabledPanel"
              class="btn-line"
              color="primary"
              :style="{
                left: `${removeButtonPosition(
                  vline,
                  style.viewer.marginLeft
                )}px`,
                transform: 'translate(-50%, 50%)',
                top: `${removeButtonPosition(
                  hlines[hlines.length - 1],
                  style.viewer.marginBottom
                )}px`
              }"
              @click="vlines.splice(index, 1)"
            >
              -
            </VBtn>
          </template>
          <div :style="style.viewer">
            <sled
              ref="sled"
              v-model:vertical-lines="vlines"
              v-model:horizontal-lines="hlines"
              :image-width="image.width"
              :image-height="image.height"
              :line-weight="lineWeight"
              autosize
              :metadata-assignment="metadata"
              :file-image="fileImage"
              :locked="sledImage.summary.length > 0"
              @resize="scale = $event.scale"
              @onComputeCells="processCells"
            />
          </div>
        </div>
        <div
          class="margin-medium-left"
          style="width: 50%"
        >
          <switch-component
            v-model="view"
            :options="tabs"
          />
          <div class="flex-separate margin-large-top">
            <div class="full_width">
              <spinner-component
                v-if="disabledPanel && view == 'Assign'"
                :show-legend="false"
                :show-spinner="false"
              />
              <component :is="componentSelected" />
            </div>
            <summary-component
              v-if="view != 'Review'"
              @update="createSled"
              @updateNew="createSled(true)"
              @updateNext="createSled(true, $event)"
              class="full_width margin-medium-left"
            />
          </div>
        </div>
      </div>
    </template>
    <upload-image
      class="full_width margin-large-top"
      v-else
      @created="createImage($event.id)"
    />
  </div>
</template>

<script>
import Sled from '@sfgrp/sled'
import ScaleValue from '@/helpers/scale'
import { Image as ImageEndpoint, SledImage, User } from '@/routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'

import VBtn from '@/components/ui/VBtn/index.vue'
import SwitchComponent from '@/components/ui/VSwitch'
import AssignComponent from './components/Assign/Main'
import UploadImage from './components/UploadImage'
import ReviewComponent from './components/Review'
import OverviewMetadataComponent from './components/Overview'
import SummaryComponent from './components/Summary'
import SpinnerComponent from '@/components/ui/VSpinner'
import QuickGrid from './components/grid/Quick'
import NavBar from './components/NavBar'
import SetParam from '@/helpers/setParam.js'
import identifierMatrix from './helpers/identifierMatrix.js'
import mergeCells from './helpers/mergeCells.js'
import { RouteNames } from '@/routes/routes.js'

export default {
  components: {
    Sled,
    SwitchComponent,
    AssignComponent,
    ReviewComponent,
    OverviewMetadataComponent,
    UploadImage,
    SummaryComponent,
    SpinnerComponent,
    QuickGrid,
    NavBar,
    VBtn
  },
  computed: {
    disabledPanel() {
      let sled = this.$store.getters[GetterNames.GetSledImage]
      return sled && sled['summary'] && sled.summary.length > 0
    },
    componentSelected() {
      return `${this.view.toPascalCase().replace(' ', '')}Component`
    },
    sledImage: {
      get() {
        return this.$store.getters[GetterNames.GetSledImage]
      },
      set(value) {
        this.$store.commit(MutationNames.SetSledImage, value)
      }
    },
    image: {
      get() {
        return this.$store.getters[GetterNames.GetImage]
      },
      set(value) {
        this.$store.commit(MutationNames.SetImage, value)
      }
    },
    identifier() {
      return this.$store.getters[GetterNames.GetIdentifier]
    }
  },
  data() {
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
          marginLeft: '40px',
          marginRight: '40px',
          marginTop: '40px',
          marginBottom: '40px'
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
        this.$nextTick(() => {
          if (this.$refs.sled) {
            this.$refs.sled.cells = this.setIdentifiers(
              newVal.metadata,
              newVal.summary
            )
          }
        })
      },
      deep: true
    }
  },
  mounted() {
    const urlParams = new URLSearchParams(window.location.search)
    const imageId = urlParams.get('image_id')
    const sledId = urlParams.get('sled_image_id')

    if (imageId && /^\d+$/.test(imageId)) {
      this.loadImage(imageId).then((response) => {
        this.loadOrCreateSled(response)
      })
    }
    if (sledId && /^\d+$/.test(sledId)) {
      SledImage.find(sledId)
        .then((sledResponse) => {
          this.loadImage(sledResponse.body.image_id).then(
            (response) => {
              if (sledResponse.body.metadata.length) {
                this.sledImage = sledResponse.body
              } else {
                sledResponse.body.metadata = this.sledImage.metadata
                this.sledImage = sledResponse.body
              }
              if (sledResponse.body.metadata.length) {
                this.setLines(
                  this.setIdentifiers(
                    sledResponse.body.metadata,
                    sledResponse.body.summary
                  )
                )
                this.$nextTick(() => {
                  this.$refs.sled.cells = sledResponse.body.metadata
                })
              }

              this.isLoading = false
            },
            () => {
              this.isLoading = false
            }
          )
        })
        .catch(() => {
          TW.workbench.alert.create('The sled image was not found', 'error')
        })
    }
  },
  methods: {
    loadPreferences() {
      User.preferences().then((response) => {
        this.preferences = response.body
        if (this.sledImage.summary.length) return
        const sizes = this.preferences.layout[this.configString]
        if (sizes) {
          this.vlines = sizes.columns.map((column) => column * this.image.width)
          this.hlines = sizes.rows.map((row) => row * this.image.height)

          if ('step_identifier_on' in sizes) {
            this.sledImage.step_identifier_on =
              sizes.step_identifier_on ?? undefined
          }

          if (sizes.horizontal_step_direction) {
            this.sledImage.horizontal_step_direction =
              sizes.horizontal_step_direction
          }

          if (sizes.vertical_step_direction) {
            this.sledImage.vertical_step_direction =
              sizes.vertical_step_direction
          }

          if (sizes.metadata)
            this.$nextTick(() => {
              this.$refs.sled.cells = this.$refs.sled.cells.map(
                (cell, index) => {
                  cell.metadata =
                    sizes.metadata[index] === 'null'
                      ? null
                      : sizes.metadata[index]
                  return cell
                }
              )
            })
        }
      })
    },
    savePreferences() {
      const columns = this.vlines.map((line) =>
        ScaleValue(line, 0, this.image.width, 0, 1)
      )
      const rows = this.hlines.map((line) =>
        ScaleValue(line, 0, this.image.height, 0, 1)
      )
      const metadata = this.$refs.sled.cells.map((cell) => `${cell.metadata}`)

      User.update(this.preferences.id, {
        user: {
          layout: {
            [this.configString]: {
              columns,
              rows,
              metadata,
              step_identifier_on: this.sledImage.step_identifier_on || null,
              horizontal_step_direction:
                this.sledImage.horizontal_step_direction,
              vertical_step_direction: this.sledImage.vertical_step_direction
            }
          }
        }
      }).then((response) => {
        this.preferences = response.body
      })
    },
    createImage(imageId) {
      this.loadImage(imageId).then((response) => {
        this.loadOrCreateSled(response)
      })
    },

    loadOrCreateSled(image) {
      return image.sled_image_id
        ? this.loadSled(image.sled_image_id)
        : this.createSledForImage(image.id)
    },
    createSledForImage(imageId) {
      this.isLoading = true

      return SledImage.create({
        sled_image: {
          image_id: imageId,
          metadata: []
        }
      }).then(
        (response) => this.loadSled(response.body.id),
        () => {
          this.isLoading = false
        }
      )
    },
    processCells(cells) {
      this.sledImage.metadata = this.sledImage.summary.length
        ? mergeCells(cells, this.sledImage.metadata)
        : cells
    },
    createSled(load = false, id = undefined) {
      this.isSaving = true
      this.savePreferences()
      this.$store.dispatch(ActionNames.UpdateSled).then(
        () => {
          this.isSaving = false

          SetParam(
            RouteNames.GridDigitizer,
            'sled_image_id',
            load ? id : this.sledImage.id
          )

          if (load) {
            this.$store.dispatch(ActionNames.ResetStore)
          }
        },
        () => {
          this.isSaving = false
        }
      )
    },
    setGrid(grid) {
      if (this.sledImage.summary.length) return
      this.$refs.sled.cells.forEach((item) => {
        item.metadata = null
      })
      this.vlines = grid.vlines
      this.hlines = grid.hlines
    },
    loadSled(sledId) {
      return new Promise((resolve, reject) => {
        SledImage.find(sledId).then(
          (response) => {
            SetParam(RouteNames.GridDigitizer, 'sled_image_id', sledId)
            if (response.body.metadata.length) {
              this.sledImage = response.body
            } else {
              response.body.metadata = this.sledImage.metadata
              this.sledImage = response.body
            }
            if (response.body.metadata.length) {
              let that = this
              this.setLines(
                this.setIdentifiers(
                  response.body.metadata,
                  response.body.summary
                )
              )
              this.$nextTick(() => {
                that.$refs.sled.cells = response.body.metadata
              })
            }

            this.isLoading = false
            resolve(response)
          },
          (resolve) => {
            reject(resolve)
          }
        )
      })
    },
    loadImage(imageId) {
      return new Promise((resolve, reject) => {
        this.isLoading = true
        ImageEndpoint.find(imageId).then(
          (response) => {
            const ajaxRequest = new XMLHttpRequest()

            this.image = response.body
            ajaxRequest.open('GET', response.body.image_display_url)
            ajaxRequest.responseType = 'blob'
            ajaxRequest.onload = () => {
              const blob = ajaxRequest.response
              const fr = new FileReader()

              fr.onloadend = () => {
                const dataUrl = fr.result
                const image = new Image()

                image.onload = () => {
                  this.image.width = image.width
                  this.image.height = image.height
                  this.fileImage = dataUrl
                  this.vlines = [0, this.image.width]
                  this.hlines = [0, this.image.height]
                  this.isLoading = false
                  this.loadPreferences()
                  resolve(response.body)
                }

                image.src = dataUrl
              }
              fr.readAsDataURL(blob)
            }
            ajaxRequest.send()
          },
          () => {
            this.isLoading = false
            reject()
          }
        )
      })
    },
    getPosition(line, next) {
      return next ? line + (next - line) / 2 : line
    },
    getButtonPosition(lines, index, margin) {
      return (
        this.getPosition(lines[index], lines[index + 1]) / this.scale +
        parseInt(margin)
      )
    },
    removeButtonPosition(line, margin) {
      return line / this.scale + parseInt(margin)
    },
    setLines(cells) {
      let xlines = []
      let ylines = []
      cells.forEach((cell) => {
        xlines.push(cell.lowerCorner.x)
        ylines.push(cell.lowerCorner.y)
        xlines.push(cell.upperCorner.x)
        ylines.push(cell.upperCorner.y)
      })
      this.vlines = [...new Set(xlines)]
      this.hlines = [...new Set(ylines)]
    },
    setIdentifiers(metadata, summary = undefined) {
      if (!this.sledImage.step_identifier_on)
        return metadata.map((cell) => {
          cell.textfield = undefined
          return cell
        })

      if (summary && summary.length) {
        return metadata.map((cell) => {
          cell.textfield = summary[cell.row][cell.column].identifier
          return cell
        })
      }

      const identifiers = this.identifier.namespace_id
        ? identifierMatrix(metadata, {
            firstIdentifier: this.identifier.identifier,
            stepIdentifierOn: this.sledImage.step_identifier_on,
            horizontalStepDirection: this.sledImage.horizontal_step_direction,
            verticalStepDirection: this.sledImage.vertical_step_direction
          })
        : new Map()

      return metadata.map((cell) => {
        const identifier = identifiers.get(`${cell.row}-${cell.column}`)

        cell.textfield = identifier
          ? `${this.identifier.label} ${identifier}`
          : undefined

        return cell
      })
    }
  }
}
</script>

<style scoped>
.btn-line {
  position: absolute;
  z-index: 10;
}
</style>
