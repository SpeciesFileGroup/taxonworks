<template>
  <div>
    <draggable-component
      group="cells"
      @add="movedObservation"
      @choose="setObservationDragged"
      @remove="removedObservationFromList">
      <div
        v-for="observation in observations"
        :key="observation.id"
        v-if="observation.hasOwnProperty('depictions')">
        <img
          v-for="depiction in observation.depictions"
          :src="depiction.image.alternatives.thumb.image_file_url"
          :width="depiction.image.alternatives.thumb.width"
          :height="depiction.image.alternatives.thumb.height"
          :key="depiction.id"
          v-html="observation.object_tag"/>
      </div>
    </draggable-component>
    <dropzone-component
      class="dropzone-card"
      ref="depiction"
      :id="`depiction-${row.id}-${column.id}`"
      url="/observations"
      :use-custom-dropzone-options="true"
      @vdropzone-sending="sending"
      @vdropzone-success="success"
      :dropzone-options="dropzone"/>
  </div>
</template>

<script>

import DropzoneComponent from 'components/dropzone'
import DraggableComponent from 'vuedraggable'
import { GetObservation, DestroyObservation, UpdateObservation } from '../request/resources'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    DropzoneComponent,
    DraggableComponent
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
    }
  },
  computed: {
    observationMoved: {
      get() {
        return this.$store.getters[GetterNames.GetObservationMoved]
      },
      set(value) {
        this.$store.commit(MutationNames.SetObservationMoved, value)
      }
    }
  },
  data() {
    return {
      newIndex: 0,
      observations: [],
      dropzone: {
        paramName: 'observation[images_attributes][][image_file]',
        url: '/observations',
        autoProcessQueue: true,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        dictDefaultMessage: 'Drop image here',
        acceptedFiles: 'image/*'
      }
    }
  },
  mounted() {
    GetObservation(this.row.row_object.global_id, this.column.descriptor.id).then(response => {
      this.observations = response.body
    })
    this.newIndex = this.index
  },
  methods: {
    removedObservationFromList(event) {
      console.log('Removed: ')
      console.log(this.observations[event.oldIndex])
      //DestroyObservation(this.observations[event.oldIndex].id).then(() => {
        this.observations.splice(event.oldIndex, 1)
      //})
    },
    movedObservation(event) {
      console.log('Added: ')
      let newObservation = {
        id: this.observationMoved.id,
        descriptor_id: this.column.descriptor_id,
        [this.row.row_object.base_class == 'Otu' ? 'otu_id' : 'collection_object_id']: this.row.row_object.id
      }
      UpdateObservation(newObservation).then((response) => {
        this.observations.push(response.body)
        this.observationMoved = undefined
      })
      console.log(this.observationMoved)
    },
    setObservationDragged(event) {
      this.observationMoved = this.observations[event.oldIndex]
    },
    success(file, response) {
      this.observations.push(response)
      this.$refs.depiction.removeFile(file)
      this.$emit('create', response)
    },
    sending(file, xhr, formData) {
      formData.append('observation[descriptor_id]', this.column.descriptor_id)
      formData.append('observation[type]', 'Observation::Media')
      formData.append(`observation[${this.row.row_object.base_class == 'Otu' ? 'otu_id' : 'collection_object_id'}]`, this.row.row_object.id)
    },
  }
}
</script>

<style scoped>
  .drag-container {
    padding: 1em;
  }
</style>
