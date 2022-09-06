<template>
  <div class="qualitative-descriptor">
    <summary-view
      :index="index"
      :descriptor="descriptor"
    >
      <smart-selector
        model="images"
        :autocomplete="false"
        :search="false"
        :target="matrixRow.observation_object.base_class"
        :add-tabs="['new', 'filter']"
        @selected="createObservation"
      >
        <template #new>
          <dropzone-component
            class="dropzone-card"
            ref="depictionObs"
            url="/observations"
            :id="`media-descriptor-${descriptor.id}`"
            :use-custom-dropzone-options="true"
            @vdropzone-sending="sending"
            @vdropzone-success="success"
            :dropzone-options="dropzoneObservation"
          />
        </template>
        <template #filter>
          <div class="horizontal-left-content align-start">
            <FilterImage @parameters="loadList" />
            <div class="margin-small-left flex-wrap-row">
              <div
                v-for="image in filterList"
                :key="image.id"
                class="thumbnail-container margin-small cursor-pointer"
                @click="createObservation(image)"
              >
                <img
                  :width="image.alternatives.thumb.width"
                  :height="image.alternatives.thumb.height"
                  :src="image.alternatives.thumb.image_file_url"
                >
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
          class="horizontal-left-content"
        >
          <image-viewer
            v-for="depiction in observation.depictions"
            :key="depiction.id"
            :depiction="depiction"
          >
            <template #thumbfooter>
              <div class="horizontal-left-content">
                <time-fields
                  :observation="observation"
                  :descriptor="descriptor"
                />
                <radial-annotator
                  type="annotations"
                  :global-id="depiction.image.global_id"
                />
                <button
                  class="button circle-button btn-delete"
                  type="button"
                  @click="removeObservation(observation)"
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
import { MutationNames } from '../../store/mutations/mutations'
import { Image } from 'routes/endpoints'
import ObservationTypes from '../../store/helpers/ObservationTypes'
import makeObservation from '../../store/helpers/makeObservation'
import summaryView from '../SummaryView/SummaryView.vue'
import FilterImage from 'tasks/images/filter/components/filter'
import SmartSelector from 'components/ui/SmartSelector'
import DropzoneComponent from 'components/dropzone'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import TimeFields from '../Time/TimeFields.vue'

export default {
  name: 'MediaDescriptor',

  components: {
    ImageViewer,
    summaryView,
    FilterImage,
    SmartSelector,
    DropzoneComponent,
    RadialAnnotator,
    TimeFields
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    index: {
      type: Number,
      required: true
    }
  },

  data () {
    return {
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

  computed: {
    matrixRow () {
      return this.$store.getters[GetterNames.GetMatrixRow]
    },

    observations () {
      return this.$store.getters[GetterNames.GetObservations].filter(o => o.descriptorId === this.descriptor.id)
    }
  },

  created () {
    const descriptorId = this.descriptor.id
    const otuId = this.matrixRow.observation_object.global_id

    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
      .then(_ => this.$store.getters[GetterNames.GetObservationsFor](descriptorId))
  },

  methods: {
    success (file, response) {
      this.addObservation(response)
      this.$refs.depictionObs.removeFile(file)
    },

    sending (file, xhr, formData) {
      formData.append('observation[descriptor_id]', this.descriptor.id)
      formData.append('observation[type]', 'Observation::Media')
      formData.append('observation[observation_object_type]', this.matrixRow.observation_object.base_class)
      formData.append('observation[observation_object_id]', this.matrixRow.observation_object.id)
      formData.append('extend[]', 'depictions')
    },

    createObservation (image) {
      this.$store.state.request.createObservation({
        observation: {
          descriptor_id: this.descriptor.id,
          depictions_attributes: [{
            image_id: image.id
          }],
          type: ObservationTypes.Media,
          observation_object_id: this.matrixRow.observation_object.id,
          observation_object_type: this.matrixRow.observation_object.base_class
        },
        extend: ['depictions']
      }).then(response => {
        this.addObservation(response)
      })
    },

    addObservation (observation) {
      const args = {
        id: observation.id,
        type: ObservationTypes.Media,
        descriptorId: this.descriptor.id,
        depictions: observation.depictions
      }

      this.$store.commit(MutationNames.AddObservation, makeObservation(args))
    },

    removeObservation (observation) {
      this.$store.dispatch(ActionNames.RemoveObservation, {
        descriptorId: this.descriptor.id,
        obsId: observation.id
      })
    },

    loadList (params) {
      Image.filter(params).then(({ body }) => {
        this.filterList = body
      })
    }
  }
}
</script>
