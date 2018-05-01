<template>
  <div id="matrix_row_coder" class="matrix-row-coder">
    <h1 class="matrix-row-coder__title" v-html="title"/>
    <div>
      <div class="flex-wrap-row flex-separate">
        <ul
          class="matrix-row-coder__descriptor-menu flex-wrap-column"
          v-for="descriptorGroup in descriptors.chunk(Math.ceil(descriptors.length/3))">
          <li v-for="descriptor in descriptorGroup">
            <div>
              <a
                class="matrix-row-coder__descriptor-item"
                :data-icon="observationsCount(descriptor.id)"
                @click="zoomDescriptor(descriptor.id)"
                v-html="descriptor.title"/>
            </div>
          </li>
        </ul>
      </div>
    </div>
    <ul class="matrix-row-coder__descriptor-list">
      <li
        class="matrix-row-coder__descriptor-container"
        v-for="descriptor in descriptors"
        :data-descriptor-id="descriptor.id">

        <div :is="descriptor.componentName" :descriptor="descriptor"/>
      </li>
    </ul>
  </div>
</template>

<style lang="stylus" src="./MatrixRowCoder.styl"></style>

<script>
import { mapState } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { ActionNames } from '../store/actions/actions'
import RadialAnnotator from '../../components/annotator/annotator'

const computed = mapState({
  title: state => state.taxonTitle,
  descriptors: state => state.descriptors
})

import continuousDescriptor from './SingleObservationDescriptor/ContinuousDescriptor/ContinuousDescriptor.vue'
import presenceDescriptor from './SingleObservationDescriptor/PresenceDescriptor/PresenceDescriptor.vue'
import qualitativeDescriptor from './QualitativeDescriptor/QualitativeDescriptor.vue'
import sampleDescriptor from './SingleObservationDescriptor/SampleDescriptor/SampleDescriptor.vue'

export default {
  created: function () {
    this.$store.state.request.setApi({
      apiBase: this.$props.apiBase,
      apiParams: this.$props.apiParams
    })

    this.$store.dispatch(ActionNames.RequestMatrixRow, {
      rowId: this.$props.rowId,
      otuId: this.$props.otuId
    })
    this.$store.dispatch(ActionNames.RequestConfidenceLevels)
  },
  name: 'MatrixRowCoder',
  props: {
    rowId: Number,
    otuId: Number,
    apiBase: String,
    apiParams: Object
  },
  computed,
  methods: {
    zoomDescriptor (descriptorId) {
      const top = document.querySelector(`[data-descriptor-id="${descriptorId}"]`).getBoundingClientRect().top
      window.scrollTo(0, top)
    },
    observationsCount(descriptorId) {
      return (this.$store.getters[GetterNames.GetObservationsFor](descriptorId).length ? 'ok' : 'no-observation')
    }
  },
  components: {
    continuousDescriptor,
    presenceDescriptor,
    qualitativeDescriptor,
    sampleDescriptor,
    RadialAnnotator
  }
}
</script>
