<template>
  <div class="depiction-container">
    <dropzone
      class="dropzone-card separate-bottom"
      @vdropzone-sending="sending"
      @vdropzone-file-added="addedfile"
      @vdropzone-success="success"
      @vdropzone-error="error"
      ref="depiction"
      :id="`depiction-${dropzoneId}`"
      url="/depictions"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"
    />
    <div
      class="flex-wrap-row"
      v-if="figuresList.length"
    >
      <image-viewer
        v-for="item in figuresList"
        @delete="removeDepiction"
        :key="item.id"
        :depiction="item"
        edit
      >
        <template #thumbfooter>
          <div
            class="horizontal-left-content padding-xsmall-bottom padding-xsmall-top gap-small"
          >
            <button
              @click="removeDepiction(item)"
              class="button circle-button btn-delete"
            />
            <zoom-image
              :data="getImageDepictionUrl(item)"
              :depiction="item"
            />
          </div>
        </template>
      </image-viewer>
    </div>
  </div>
</template>

<script>
import ActionNames from '../../store/actions/actionNames'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer'
import Dropzone from '@/components/dropzone.vue'
import { Depiction } from '@/routes/endpoints'
import ZoomImage from './zoomImage.vue'
import { imageSVGViewBox } from '@/helpers/images'

export default {
  components: {
    ImageViewer,
    Dropzone,
    ZoomImage
  },
  props: {
    actionSave: {
      type: String,
      required: true
    },
    objectValue: {
      type: Object,
      required: true
    },
    objectType: {
      type: String,
      required: true
    },
    defaultMessage: {
      type: String,
      default: 'Drop images or click here to add figures'
    }
  },

  emits: ['create', 'delete'],

  data() {
    return {
      creatingType: false,
      displayBody: true,
      figuresList: [],
      dropzoneId: Math.random().toString(36).substr(2, 5),
      dropzone: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: false,
        headers: {
          'X-CSRF-Token': document
            .querySelector('meta[name="csrf-token"]')
            .getAttribute('content')
        },
        dictDefaultMessage: this.defaultMessage,
        acceptedFiles: 'image/*,.heic'
      }
    }
  },

  watch: {
    objectValue(newVal, oldVal) {
      if (newVal.id && newVal.id != oldVal.id) {
        this.$refs.depiction.setOption('autoProcessQueue', true)
        this.$refs.depiction.processQueue()
        Depiction.where({
          depiction_object_id: newVal.id,
          depiction_object_type: this.objectType
        })
          .then((response) => {
            this.figuresList = response.body
          })
          .catch(() => {})
      } else if (!newVal.id) {
        this.figuresList = []
        this.$refs.depiction.setOption('autoProcessQueue', false)
      }
    }
  },

  created() {
    if (this.objectValue.id) {
      this.getDepictions(this.objectValue.id).then((response) => {
        this.figuresList = response.body
      })
    }
  },
  methods: {
    success(file, response) {
      this.figuresList.push(response)
      this.$refs.depiction.removeFile(file)
      this.$emit('create', response)
    },

    sending(file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.objectValue.id)
      formData.append('depiction[depiction_object_type]', this.objectType)
    },

    addedfile() {
      if (!this.objectValue.id && !this.creatingType) {
        this.creatingType = true
        this.$store.dispatch(ActionNames[this.actionSave]).then(
          (data) => {
            if (!data?.id) return
            setTimeout(() => {
              this.$refs.depiction.setOption('autoProcessQueue', true)
              this.$refs.depiction.processQueue()
              this.creatingType = false
            }, 500)
          },
          () => {
            this.creatingType = false
          }
        )
      }
    },

    removeDepiction(depiction) {
      if (window.confirm('Are you sure want to proceed?')) {
        Depiction.destroy(depiction.id).then(() => {
          TW.workbench.alert.create(
            'Depiction was successfully deleted.',
            'notice'
          )
          this.figuresList.splice(
            this.figuresList.findIndex((figure) => figure.id === depiction.id),
            1
          )
          this.$emit('delete', depiction)
        })
      }
    },

    error(event) {
      TW.workbench.alert.create(
        `There was an error uploading the image: ${event.xhr.responseText}`,
        'error'
      )
    },

    getImageDepictionUrl(depiction) {
      return depiction.svg_view_box
        ? this.makeSVGViewbox(depiction)
        : {
            imageUrl: depiction.image.image_display_url,
            width: depiction.image.width,
            height: depiction.image.height
          }
    },

    makeSVGViewbox(depiction) {
      const width = Math.floor(window.innerWidth * 0.75)
      const height =
        window.innerHeight * 0.4 < 400
          ? Math.floor(window.innerHeight * 0.4)
          : 400
      const imageUrl = imageSVGViewBox(
        depiction.image.id,
        depiction.svg_view_box,
        width,
        height
      )

      return {
        imageUrl,
        width,
        height
      }
    }
  }
}
</script>
<style scoped>
.depiction-container {
  width: 100%;
  max-width: 100%;
}
</style>
