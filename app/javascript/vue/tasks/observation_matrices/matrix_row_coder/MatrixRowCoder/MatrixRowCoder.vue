<template>
  <div id="matrix_row_coder" class="matrix-row-coder">
    <spinner
      legend="Loading..."
      :full-screen="true"
      :logo-size="{ width: '50px', height: '50px'}"
      v-if="isLoading"/>
    <div class="flex-separate">
      <h1 class="matrix-row-coder__title" v-html="title"/>
    </div>
    <div>
      <div class="flex-separate margin-medium-bottom">
        <div>
          <div class="align-start">
            <ul
              class="matrix-row-coder__descriptor-menu flex-wrap-column"
              v-for="descriptorGroup in descriptors.chunk(Math.ceil(descriptors.length/3))">
              <li v-for="descriptor in descriptorGroup">
                <div>
                  <a
                    class="matrix-row-coder__descriptor-item"
                    :data-icon="observationsCount(descriptor.id) ? 'ok' : false"
                    @click="zoomDescriptor(descriptor.id)"
                    v-html="descriptor.title"/>
                </div>
              </li>
            </ul>
          </div>
          <description-main/>
        </div>
        <div>
          <destroy-all-observations
            @onConfirm="destroyAllObservations"/>
          <clone-scoring
            @onCopy="copyScorings"
            @onClone="cloneScorings"/>
        </div>
      </div>
    </div>

    <ul class="matrix-row-coder__descriptor-list no_bullets">
      <li
        class="matrix-row-coder__descriptor-container"
        v-for="(descriptor, index) in descriptors"
        :key="descriptor.id"
        :data-descriptor-id="descriptor.id">
        <component
          :is="descriptor.componentName"
          :index="(index+1)"
          :descriptor="descriptor"/>
      </li>
    </ul>
  </div>
</template>

<style lang="stylus" src="./MatrixRowCoder.styl"></style>

<script>
import { mapState } from 'vuex'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import ContinuousDescriptor from './SingleObservationDescriptor/ContinuousDescriptor/ContinuousDescriptor.vue'
import FreeTextDescriptor from './SingleObservationDescriptor/FreeText/FreeText.vue'
import PresenceDescriptor from './SingleObservationDescriptor/PresenceDescriptor/PresenceDescriptor.vue'
import QualitativeDescriptor from './QualitativeDescriptor/QualitativeDescriptor.vue'
import SampleDescriptor from './SingleObservationDescriptor/SampleDescriptor/SampleDescriptor.vue'
import MediaDescriptor from './MediaDescriptor/MediaDescriptor.vue'
import Spinner from 'components/spinner'
import CloneScoring from './Clone/Clone'
import DestroyAllObservations from './ObservationRow/destroyObservationRow'
import DescriptionMain from './Description/DescriptionMain.vue'

const computed = mapState({
  title: state => state.taxonTitle,
  descriptors: state => state.descriptors
})

export default {
  created () {
    this.loadMatrixRow({
      rowId: this.$props.rowId,
      otuId: this.$props.otuId
    })
    this.$store.dispatch(ActionNames.RequestUnits)
  },
  data () {
    return {
      isLoading: false
    }
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
    setApiValues () {
      this.$store.state.request.setApi({
        apiBase: this.$props.apiBase,
        apiParams: this.$props.apiParams
      })
    },
    zoomDescriptor (descriptorId) {
      const top = document.querySelector(`[data-descriptor-id="${descriptorId}"]`).getBoundingClientRect().top
      window.scrollTo(0, top)
    },
    observationsCount(descriptorId) {
      return this.$store.getters[GetterNames.GetObservationsFor](descriptorId).find((item) => {
        return item.id != null
      })
    },
    loadMatrixRow(matrixRow) {
      this.$store.commit(MutationNames.ResetState)
      this.setApiValues()
      this.isLoading = true
      this.$store.dispatch(ActionNames.RequestMatrixRow, matrixRow).then(() => {
        this.isLoading = false
      })
      this.$store.dispatch(ActionNames.RequestDescription, matrixRow.rowId)
      this.$store.dispatch(ActionNames.RequestConfidenceLevels)
    },
    destroyAllObservations () {
      this.$store.dispatch(ActionNames.RemoveObservationsRow, this.rowId).then(() => {
        this.loadMatrixRow({
          rowId: this.rowId,
          otuId: this.otuId
        })
      })
    },
    cloneScorings(args) {
      this.isLoading = true
      this.$store.dispatch(ActionNames.CreateClone, args).then(() => {
        this.isLoading = false
      }, () => {
        this.isLoading = false
      })
    },
    copyScorings(args) {
      this.isLoading = true
      this.$store.dispatch(ActionNames.CreateClone, args).then(() => {
        this.isLoading = false
        this.loadMatrixRow({
          rowId: this.rowId,
          otuId: this.otuId
        })
      }, () => {
        this.isLoading = false
      })
    }
  },
  components: {
    CloneScoring,
    ContinuousDescriptor,
    FreeTextDescriptor,
    PresenceDescriptor,
    QualitativeDescriptor,
    SampleDescriptor,
    MediaDescriptor,
    Spinner,
    DestroyAllObservations,
    DescriptionMain
  }
}
</script>
