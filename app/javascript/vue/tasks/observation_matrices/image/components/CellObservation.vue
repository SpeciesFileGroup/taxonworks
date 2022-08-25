<template>
  <div title="Drop image here">
    <spinner-component
      :legend="('Uploading...')"
      v-if="isLoading"
    />
    <dropzone-component
      v-show="show"
      class="dropzone-card"
      ref="dropzone"
      url="/observations"
      use-custom-dropzone-options
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      @click="openInputFile"
      :dropzone-options="
        existObservations
          ? dropzoneDepiction
          : dropzoneObservation
      "
    >
      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        group="cells"
        item-key="id"
        :list="depictions"
        @click.stop="openInputFile"
        @add="movedDepiction"
        @choose="setObservationDragged"
      >
        <template #item="{ element }">
          <div
            @click.stop
            title=""
            class="drag-container"
          >
            <image-viewer
              edit
              :depiction="element"
            >
              <template #thumbfooter>
                <div class="horizontal-left-content margin-small-top">
                  <radial-annotator
                    type="annotations"
                    :global-id="element.image.global_id"
                  />
                  <button-citation
                    :global-id="element.image.global_id"
                    :citations="element.image.citations"
                  />
                  <button
                    class="button circle-button btn-delete"
                    type="button"
                    @click="removeDepiction(element)"
                  />
                </div>
              </template>
            </image-viewer>
          </div>
        </template>
      </draggable-component>
    </dropzone-component>
    <v-icon
      v-if="!show && existObservations"
      name="image"
    />
  </div>
</template>

<script>

import DropzoneComponent from 'components/dropzone'
import DraggableComponent from 'vuedraggable'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import SpinnerComponent from 'components/spinner'
import VIcon from 'components/ui/VIcon/index.vue'
import ButtonCitation from './ButtonCitation.vue'
import { Observation, Depiction } from 'routes/endpoints'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    DropzoneComponent,
    DraggableComponent,
    SpinnerComponent,
    ImageViewer,
    VIcon,
    RadialAnnotator,
    ButtonCitation
  },

  props: {
    depictions: {
      type: Array,
      required: true
    },

    rowObject: {
      type: Object,
      required: true
    },

    column: {
      type: Object,
      required: true
    },

    show: {
      type: Boolean,
      default: true
    }
  },

  emits: [
    'removeDepiction',
    'addDepiction'
  ],

  computed: {
    observationMoved: {
      get () {
        return this.$store.getters[GetterNames.GetObservationMoved]
      },
      set (value) {
        this.$store.commit(MutationNames.SetObservationMoved, value)
      }
    },

    depictionMoved: {
      get () {
        return this.$store.getters[GetterNames.GetDepictionMoved]
      },
      set (value) {
        this.$store.commit(MutationNames.SetDepictionMoved, value)
      }
    },

    existObservations () {
      return this.depictions.length > 0
    },

    rowObjectId () {
      return this.rowObject.observation_object_id || this.rowObject.id
    },

    rowObjectBaseCassParam () {
      return this.rowObject.observation_object_type || this.rowObject.base_class
    },

    observationId () {
      return this.depictions.length && this.depictions[0].depiction_object_id
    }
  },

  data () {
    return {
      isLoading: false,
      dropzoneObservation: {
        paramName: 'observation[images_attributes][][image_file]',
        url: '/observations',
        autoProcessQueue: true,
        parallelUploads: 1,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        acceptedFiles: 'image/*,.heic'
      },
      dropzoneDepiction: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: true,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        acceptedFiles: 'image/*,.heic'
      }
    }
  },

  methods: {
    movedDepiction (event) {
      if (this.depictions.length === 1) {
        const observation = {
          descriptor_id: this.column.id,
          type: 'Observation::Media',
          observation_object_type: this.rowObjectBaseCassParam,
          observation_object_id: this.rowObjectId
        }

        Observation.create({ observation, extend: ['depictions'] }).then(({ body }) => {
          this.updateDepiction(body.id)
        })
      } else {
        this.updateDepiction()
      }
    },

    openInputFile () {
      this.$refs.dropzone.$el.click()
    },

    updateDepiction (observationId) {
      const depiction = {
        id: this.depictionMoved.id,
        depiction_object_id: observationId || this.observationId,
        depiction_object_type: 'Observation'
      }
      const observation = {
        id: this.observationMoved,
        depictions_attributes: [depiction]
      }

      this.$store.commit(MutationNames.SetIsSaving, true)

      const request = observation.id
        ? Observation
          .update(observation.id, { observation, extend: ['depictions'] })
          .then(({ body }) => {
            const existDepiction = body.depictions.find(d => d.depiction_object_id === this.observationMoved)

            if (!existDepiction) {
              Observation.destroy(body.id)
            }

            this.$emit('addDepiction', {
              ...this.depictionMoved,
              ...depiction
            })
          })
        : Depiction.update(depiction.id, { depiction }).then(({ body }) => {
          this.$emit('addDepiction', body)
        })

      request.finally(() => {
        this.depictionMoved = undefined
        this.observationMoved = undefined
        this.$store.commit(MutationNames.SetIsSaving, false)
      })
    },

    setObservationDragged (event) {
      this.depictionMoved = this.depictions[event.oldIndex]
      this.observationMoved = this.observationId
    },

    removeDepiction (depiction) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$store.commit(MutationNames.SetIsSaving, true)
        Depiction.destroy(depiction.id).then(() => {
          const index = this.depictions.findIndex(item => item.id === depiction.id)

          this.$emit('removeDepiction', index)
          this.$store.commit(MutationNames.SetIsSaving, false)
        })
      }
    },

    success (file, response) {
      if (!this.existObservations) {
        this.$refs.dropzone.setOption('url', this.dropzoneDepiction.url)
        this.$refs.dropzone.setOption('paramName', this.dropzoneDepiction.paramName)
      }

      this.$emit('addDepiction', response.base_class === 'Depiction' ? response : response.depictions[0])

      this.$refs.dropzone.removeFile(file)
      this.isLoading = false
    },

    sending (file, xhr, formData) {
      if (this.existObservations) {
        formData.append('depiction[depiction_object_id]', this.observationId)
        formData.append('depiction[depiction_object_type]', 'Observation')
      } else {
        formData.append('observation[descriptor_id]', this.column.id)
        formData.append('observation[type]', 'Observation::Media')
        formData.append('observation[observation_object_id]', this.rowObjectId)
        formData.append('observation[observation_object_type]', this.rowObjectBaseCassParam)
        formData.append('extend[]', 'depictions')
      }

      this.isLoading = true
    }
  }
}
</script>

<style scoped>
  .dropzone-card {
    align-items: stretch;
    flex: 1
  }

  :deep(.dz-message) {
    margin: 1em 0 !important;
    font-size: 16px !important;
    display: none !important;
  }

  .matrix-image-draggable {
    box-sizing: content-box;
    align-items: stretch;
    flex: 1;
    height: 100%;
    cursor: pointer;
  }

  .vue-dropzone {
    padding: 0px !important;
    min-width: 100px;
    cursor: pointer !important;
    align-items: stretch;
    flex: 1;
  }

  .dropzone {
    height: 100%;
  }

  .image-draggable {
    cursor: pointer;
  }

  :deep(.dz-preview) {
    display: none !important;
  }

</style>
