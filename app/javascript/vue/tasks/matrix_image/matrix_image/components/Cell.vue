<template>
  <div>
    <div v-show="show">
      <spinner-component
        :legend="('Loading...')"
        v-if="isLoading"/>
      <template>
        <div v-show="existObservations">
          <dropzone-component
            class="dropzone-card"
            ref="depictionDepic"
            url="/depictions"
            :id="`depiction-${row.id}-${column.id}-depic-${Math.random().toString(36).slice(2)}`"
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
            :id="`depiction-${row.id}-${column.id}-obs-${Math.random().toString(36).slice(2)}`"
            :use-custom-dropzone-options="true"
            @vdropzone-sending="sending"
            @vdropzone-success="success"
            :dropzone-options="dropzoneObservation"/>
          </div>
      </template>

      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        group="cells"
        @add="movedObservation"
        @choose="setObservationDragged"
        @remove="removedObservationFromList">
        <template v-if="observationsMedia.length && observationsMedia[0].hasOwnProperty('depictions')">
          <div
            v-for="depiction in observationsMedia[0].depictions"
            :key="depiction.id"
            class="drag-container">
            <depiction-modal-viewer
              :depiction="depiction"
              is-original
              @delete="removeDepiction"
            />
          </div>
        </template>
      </draggable-component>
    </div>
    <div
      v-if="!show && existObservations"
      class="background-cell-image"/>
  </div>
</template>

<script>

import DropzoneComponent from 'components/dropzone'
import DraggableComponent from 'vuedraggable'
import DepictionModalViewer from 'components/depictionModalViewer/depictionModalViewer.vue'
import SpinnerComponent from 'components/spinner'
import { 
  GetObservation, 
  DestroyObservation, 
  UpdateObservation, 
  UpdateDepiction,
  DestroyDepiction,
  CreateObservation
  } from '../request/resources'

import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    DropzoneComponent,
    DraggableComponent,
    SpinnerComponent,
    DepictionModalViewer
  },
  props: {
    row: {
      type: Object,
      required: true
    },
    column: {
      type: Object,
      required: true
    },
    index: {
      type: [Number, String]
    },
    show: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    getImage() {
      return Image
    },
    observationMoved: {
      get() {
        return this.$store.getters[GetterNames.GetObservationMoved]
      },
      set(value) {
        this.$store.commit(MutationNames.SetObservationMoved, value)
      }
    },
    depictionMoved: {
      get() {
        return this.$store.getters[GetterNames.GetDepictionMoved]
      },
      set(value) {
        this.$store.commit(MutationNames.SetDepictionMoved, value)
      }
    },
    observationsMedia() {
      return this.observations
    },
    existObservations() {
      return this.observations.length > 0
    }
  },
  data() {
    return {
      observations: [],
      isLoading: true,
      dropzoneObservation: {
        paramName: 'observation[images_attributes][][image_file]',
        url: '/observations',
        autoProcessQueue: true,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop<br>image<br>here',
        acceptedFiles: 'image/*,.heic'
      },
      dropzoneDepiction: {
        paramName: 'depiction[image_attributes][image_file]',
        url: '/depictions',
        autoProcessQueue: true,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop<br>image<br>here',
        acceptedFiles: 'image/*,.heic'
      }
    }
  },
  watch: {
    row: {
      handler () {
        this.isLoading = true
        GetObservation(this.row.row_object.global_id, this.column.descriptor.id).then(response => {
          this.observations = response.body.filter((item) => {
            return item.type == 'Observation::Media'
          })
          this.isLoading = false
        })
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    removedObservationFromList(event) {
      if(this.observationsMedia[0].depictions.length == 1) {
          this.observations.splice(event.oldIndex, 1)
      }
      else {
        let index = this.observations.findIndex(item => {
          return item.id == this.observationsMedia[0].id
        })
        this.observations[index].depictions.splice([event.oldIndex], 1)
      }
    },
    movedObservation(event) {
      if(this.observationsMedia.length) {
        this.updateDepiction()
      }
      else {
        let newObservation = {
          descriptor_id: this.column.descriptor_id,
          type: 'Observation::Media',
          [this.row.row_object.base_class == 'Otu' ? 'otu_id' : 'collection_object_id']: this.row.row_object.id,
        }
        CreateObservation(newObservation).then(response => {
          this.observations.push(response.body)
          this.updateDepiction()         
        })
      }
    },
    updateDepiction() {
     let newDepiction = {
        id: this.depictionMoved.id,
        depiction_object_id: this.observationsMedia[0].id, 
        depiction_object_type: this.observationsMedia[0].base_class,
      }
      let changeObservation = {
        id: this.observationMoved.id,
        depictions_attributes: [newDepiction]
      }
      UpdateObservation(changeObservation).then(response => {
        if(!response.body.hasOwnProperty('depictions')) {
          DestroyObservation(response.body.id)
        }
      })
      this.$store.commit(MutationNames.SetIsSaving, true)
      UpdateDepiction(newDepiction).then((response) => {
        let index = this.observations.findIndex(item => {
          return item.id == this.observationsMedia[0].id
        })
        if(this.observations[index].hasOwnProperty('depictions'))
          this.observations[index].depictions.push(response.body)
        else
          this.$set(this.observations[index],'depictions', [response.body])
        this.depictionMoved = undefined
        this.observationMoved = undefined
        this.$store.commit(MutationNames.SetIsSaving, false)
      })      
    },
    setObservationDragged(event) {
      this.depictionMoved = this.observationsMedia[0].depictions[event.oldIndex]
      this.observationMoved = this.observationsMedia[0]
    },
    removeDepiction(depiction) {
      this.$store.commit(MutationNames.SetIsSaving, true)
      DestroyDepiction(depiction.id).then(() => {
        let index = this.observations[0].depictions.findIndex(item => {
          return item.id === depiction.id
        })
        this.observations[0].depictions.splice(index, 1)
        if(!this.observations[0].depictions.length) {
          DestroyObservation(this.observations[0].id).then(() => {
            this.observations.splice(0, 1)
            this.$store.commit(MutationNames.SetIsSaving, false)
          })
        }
        else {
          this.$store.commit(MutationNames.SetIsSaving, false)
        }
      })
    },
    success(file, response) {
      this.observations.push(response)
      this.$refs.depictionObs.removeFile(file)
      this.$emit('create', response)
    },
    sending(file, xhr, formData) {
      formData.append('observation[descriptor_id]', this.column.descriptor_id)
      formData.append('observation[type]', 'Observation::Media')
      formData.append(`observation[${this.row.row_object.base_class == 'Otu' ? 'otu_id' : 'collection_object_id'}]`, this.row.row_object.id)
    },
    successDepic(file, response) {
      this.observations[0].depictions.push(response)
      this.$refs.depictionDepic.removeFile(file)
      this.$emit('create', response)
    },
    sendingDepic(file, xhr, formData) {
      formData.append('depiction[depiction_object_id]', this.observations[0].id)
      formData.append('depiction[depiction_object_type]', this.observations[0].base_class)
    },
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

  ::v-deep .dz-message {
    margin: 1em 0 !important;
  }

  .background-cell-image {
    width: 25px;
    height: 20px;
    background-size: 20px;
    background-position: center;
    background-repeat: no-repeat;
    background-image: url('../assets/images/image.svg')
  }
  
  .matrix-image-draggable {
    min-height: 100px;
    box-sizing: content-box;
  }
</style>
