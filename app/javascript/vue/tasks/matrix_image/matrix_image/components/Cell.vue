<template>
  <div>
    <draggable-component
      group="cells"
      v-model="images"
      @add="movedObservation"
      @remove="removedObservationFromList">
      <div v-if="observations.length">
        <span
          v-for="observation in observations"
          :key="observation.id"
          v-html="observation.object_tag"/>
      </div>
      <span v-for="image in images">{{ image }}</span>
    </draggable-component>
    <dropzone-component
      class="dropzone-card"
      ref="depiction"
      :id="`depiction-${row.id}-${column.id}`"
      url="/depictions"
      :use-custom-dropzone-options="true"
      :dropzone-options="dropzone"/>
  </div>
</template>

<script>

import DropzoneComponent from 'components/dropzone'
import DraggableComponent from 'vuedraggable'
import { GetObservation } from '../request/resources'

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
  data() {
    return {
      newIndex: 0,
      observations: [],
      images: [1, 2, 3],
      dropzone: {
        paramName: 'observation[depiction][image_attributes][image_file]',
        url: '/observations',
        autoProcessQueue: false,
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
      console.log(event)
    },
    movedObservation(event) {
      console.log('Added: ')
      console.log(event)
    }
  }
}
</script>

<style scoped>
  .drag-container {
    padding: 1em;
  }
</style>
