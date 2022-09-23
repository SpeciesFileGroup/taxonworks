<template>
  <div>
    <spinner-component
      full-screen
      :legend="isSaving ? 'Saving...' : 'Loading...'"
      v-if="isLoading || isSaving"
    />
    <h1>Free form</h1>
    <nav-bar />
    <template v-if="image">
      <div class="horizontal-left-content align-start">
        <div
          class="horizontal-left-content align-start"
          style="width: 50%;"
        >
          <DrawControls class="margin-medium-right" />
          <DrawBoard
            v-if="image"
            :image="image"
          />
        </div>
        <div
          class="margin-medium-left"
          style="width: 50%;"
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
              class="full_width margin-medium-left"
              @update="createSled"
              @update-new="createSled(true)"
              @update-next="createSled(true, $event)"
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

import { GetImage, GetSledImage } from './request/resource'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'
import DrawBoard from './components/DrawBoard/DrawBoard.vue'
import DrawControls from './components/DrawBoard/DrawControls.vue'

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
    NavBar,
    DrawBoard,
    DrawControls
  },
  computed: {
    disabledPanel () {
      const sled = this.$store.getters[GetterNames.GetSledImage]

      return sled?.summary && sled.summary.length > 0
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
      view: 'Assign'
    }
  },
  created () {
    const urlParams = new URLSearchParams(window.location.search)
    const sledId = urlParams.get('sled_image_id')

    if (sledId && /^\d+$/.test(sledId)) {
      this.$store.dispatch(ActionNames.LoadSledImage, sledId)
    }
  },

  methods: {
    createImage (imageId) {
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
          const ajaxRequest = new XMLHttpRequest()

          this.image = response.body
          ajaxRequest.open('GET', response.body.image_display_url)
          ajaxRequest.responseType = 'blob'
          ajaxRequest.onload = () => {
            const blob = ajaxRequest.response
            const fr = new FileReader()

            fr.onloadend = () => {
              const dataUrl = fr.result
              const image = new Image

              image.onload = () => {
                this.fileImage = dataUrl
                this.isLoading = false
                resolve(response.body)
              }

              image.src = dataUrl
            }
            fr.readAsDataURL(blob)
          }
          ajaxRequest.send()
        }, () => {
          this.isLoading = false
          reject()
        })
      })
    }
  }
}
</script>
