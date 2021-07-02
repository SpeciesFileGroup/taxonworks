<template>
  <div class="qualitative-descriptor">
    <summary-view
      :index="index"
      :descriptor="descriptor">
      <smart-selector
        model="images"
        :autocomplete="false"
        :search="false"
        :target="matrixRow.row_object.base_class"
        :addTabs="['new', 'filter']"
        @selected="createObservation">
        <template #new>
          <dropzone-component
            class="dropzone-card"
            ref="depictionObs"
            url="/observations"
            :id="`media-descriptor-${descriptor.id}`"
            :use-custom-dropzone-options="true"
            @vdropzone-sending="sending"
            @vdropzone-success="success"
            :dropzone-options="dropzoneObservation"/>
        </template>
        <template #filter>
          <div class="horizontal-left-content align-start">
            <filter-image
              @result="loadList"/>
            <div class="margin-small-left flex-wrap-row">
              <div
                v-for="image in filterList"
                :key="image.id"
                class="thumbnail-container margin-small cursor-pointer"
                @click="createObservation(image)">
                <img
                  :width="image.alternatives.thumb.width"
                  :height="image.alternatives.thumb.height"
                  :src="image.alternatives.thumb.image_file_url">
              </div>
            </div>
          </div>
        </template>
      </smart-selector>
      <h3>
        Created
      </h3>
      <ul class="no_bullets">
        <li
          v-for="observation in observations"
          :key="observation.id"
          class="horizontal-left-content">
          <image-viewer
            v-for="depiction in observation.depictions"
            :key="depiction.id"
            :depiction="depiction">
            <template #thumbfooter>
              <div class="horizontal-left-content">
                <radial-annotator
                  type="annotations"
                  :global-id="depiction.image.global_id"/>
                <button
                  class="button circle-button btn-delete"
                  type="button"
                  @click="destroyObservation(observation.id)"
                />
              </div>
            </template>
          </image-viewer>
        </li>
      </ul>
    </summary-view>
  </div>
</template>

<style src="./QualitativeDescriptor.styl" lang="stylus"></style>

<script>
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'

import summaryView from '../SummaryView/SummaryView.vue'
import FilterImage from 'tasks/images/filter/components/filter'
import SmartSelector from 'components/ui/SmartSelector'
import DropzoneComponent from 'components/dropzone'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'

export default {
  name: 'MediaDescriptor',

  props: ['descriptor', 'index'],

  created () {
    const descriptorId = this.$props.descriptor.id
    const otuId = this.matrixRow.row_object.global_id

    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
      .then(_ => this.$store.getters[GetterNames.GetObservationsFor](descriptorId))
      .then(observations => {
        this.observations = observations
      })
  },

  computed: {
    matrixRow () {
      return this.$store.getters[GetterNames.GetMatrixRow]
    }
  },

  data () {
    return {
      observations: [],
      filterList: [],
      dropzoneObservation: {
        paramName: 'observation[images_attributes][][image_file]',
        url: '/observations',
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
    loadList (newList) {
      this.filterList = newList
    },

    success (file, response) {
      this.observations.push(response)
      this.$refs.depictionObs.removeFile(file)
    },

    sending (file, xhr, formData) {
      formData.append('observation[descriptor_id]', this.descriptor.id)
      formData.append('observation[type]', 'Observation::Media')
      formData.append(`observation[${this.matrixRow.row_object.base_class === 'Otu' ? 'otu_id' : 'collection_object_id'}]`, this.matrixRow.row_object.id)
    },

    destroyObservation (observationId) {
      this.$store.state.request.removeObservation(observationId).then(() => {
        this.observations.splice(this.observations.findIndex(o => o.id === observationId), 1)
      })
    },

    createObservation (image) {
      this.$store.state.request.createObservation({
        observation: {
          descriptor_id: this.descriptor.id,
          depictions_attributes: [{
            image_id: image.id
          }],
          type: 'Observation::Media',
          [(this.matrixRow.row_object.base_class === 'Otu' ? 'otu_id' : 'collection_object_id')]: this.matrixRow.row_object.id
        }
      }).then(response => {
        this.observations.push(response)
      })
    }
  },
  components: {
    ImageViewer,
    summaryView,
    FilterImage,
    SmartSelector,
    DropzoneComponent,
    RadialAnnotator
  }
}
</script>
