<template>
  <div>
    <div v-show="show">
      <spinner-component
        :legend="('Loading...')"
        v-if="isLoading"/>
      <div v-show="existObservations">
        <dropzone-component
          class="dropzone-card"
          ref="depictionDepic"
          url="/depictions"
          :use-custom-dropzone-options="true"
          @vdropzone-sending="sendingDepic"
          @vdropzone-success="successDepic"
          :dropzone-options="dropzoneDepiction"/>
      </div>
      <div v-show="!existObservations">
        <dropzone-component
          class="dropzone-card"
          ref="depictionObs"
          url="/observations"
          :use-custom-dropzone-options="true"
          @vdropzone-sending="sending"
          @vdropzone-success="success"
          :dropzone-options="dropzoneObservation"/>
      </div>

      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        group="cells"
        item-key="id"
        :list="depictions"
        @add="movedDepiction"
        @choose="setObservationDragged"
      >
        <template #item="{ element }">
          <div class="drag-container">
            <image-viewer
              edit
              :depiction="element"
            >
              <template #thumbfooter>
                <div class="horizontal-left-content">
                  <radial-annotator
                    type="annotations"
                    :global-id="element.image.global_id"/>
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
    </div>
    <v-icon
      v-if="!show && existObservations"
      name="image"/>
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
    'removeDepictions',
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
      return this.rowObject.otu_id || this.rowObject.collection_object_id
    },

    rowObjectBaseCassParam () {
      return this.rowObject.otu_id ? 'otu_id' : 'collection_object_id'
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
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop image here',
        acceptedFiles: 'image/*,.heic'
      },
      dropzoneDepiction: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: true,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop image here',
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
          [this.rowObjectBaseCassParam]: this.rowObjectId
        }

        Observation.create({ observation }).then(({ body }) => {
          this.updateDepiction(event, body.id)
        })
      }
      else {
        this.updateDepiction(event)
      }
    },

    async updateDepiction (event, observationId) {
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

      if (observation.id) {
        await Observation.update(observation.id, { observation }).then(({ body }) => {
          if (!body.depictions.find(d => d.depiction_object_id === this.observationMoved)) {
            Observation.destroy(body.id)
          }
        })
      }

      Depiction.update(depiction.id, { depiction }).then(({ body }) => {
        this.$emit('addDepiction', body)
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
          const observationId = this.observationId

          this.$emit('removeDepiction', index)
          this.$store.commit(MutationNames.SetIsSaving, false)
        })
      }
    },

    success (file, response) {
      this.$emit('addDepiction', response.depictions[0])
      this.$refs.depictionObs.removeFile(file)
    },

    sending (file, xhr, formData) {
      formData.append('observation[descriptor_id]', this.column.id)
      formData.append('observation[type]', 'Observation::Media')
      formData.append(`observation[${this.rowObjectBaseCassParam}]`, this.rowObjectId)
    },

    successDepic (file, response) {
      this.$emit('addDepiction', response)
      this.$refs.depictionDepic.removeFile(file)
    },

    sendingDepic (file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.observationId)
      formData.append('depiction[depiction_object_type]', 'Observation')
    }
  }
}
</script>

<style scoped>
  .drag-container {
    padding-top: 0.5em;
  }

  .dropzone-card {
    min-height: 100px !important;
    height: 100px;
  }

  :deep(.dz-message) {
    margin: 1em 0 !important;
    font-size: 16px !important;
  }

  .matrix-image-draggable {
    min-height: 100px;
    box-sizing: content-box;
  }
</style>
