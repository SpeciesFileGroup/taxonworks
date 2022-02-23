<template>
  <div
    id="matrix-row-coder-app"
    class="matrix-row-coder">
    <spinner
      legend="Loading..."
      full-screen
      :logo-size="{ width: '50px', height: '50px'}"
      v-if="isLoading"
    />
    <navbar-component>
      <div class="flex-separate middle">
        <h3
          class="matrix-row-coder__title"
          v-html="title"
        />
        <div class="horizontal-left-content">
          <diagnosis-component class="margin-small-right"/>
          <descriptors-list class="margin-small-right"/>
          <description-main class="margin-small-right"/>
          <clone-scoring
            class="margin-small-right"
            @on-copy="copyScorings"
            @on-clone="cloneScorings"
          />
          <destroy-all-observations @on-confirm="destroyAllObservations"/>
        </div>
      </div>
    </navbar-component>

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
import { MutationNames } from '../store/mutations/mutations'
import { ActionNames } from '../store/actions/actions'
import ContinuousDescriptor from './ContinuousDescriptor/ContinuousDescriptor.vue'
import FreeTextDescriptor from './SingleObservationDescriptor/FreeText/FreeText.vue'
import PresenceDescriptor from './SingleObservationDescriptor/PresenceDescriptor/PresenceDescriptor.vue'
import SampleDescriptor from './SingleObservationDescriptor/SampleDescriptor/SampleDescriptor.vue'
import QualitativeDescriptor from './QualitativeDescriptor/QualitativeDescriptor.vue'
import MediaDescriptor from './MediaDescriptor/MediaDescriptor.vue'
import Spinner from 'components/spinner'
import CloneScoring from './Clone/Clone'
import DestroyAllObservations from './ObservationRow/destroyObservationRow'
import DescriptionMain from './Description/DescriptionMain.vue'
import DescriptorsList from './Descriptors/DescriptorsList.vue'
import DiagnosisComponent from './Diagnosis/Diagnosis.vue'
import NavbarComponent from 'components/layout/NavBar.vue'

const computed = mapState({
  title: state => state.taxonTitle,
  descriptors: state => state.descriptors
})

export default {
  name: 'MatrixRowCoder',

  components: {
    DescriptorsList,
    NavbarComponent,
    CloneScoring,
    ContinuousDescriptor,
    FreeTextDescriptor,
    PresenceDescriptor,
    QualitativeDescriptor,
    SampleDescriptor,
    MediaDescriptor, 
    Spinner,
    DestroyAllObservations,
    DescriptionMain,
    DiagnosisComponent
  },

  props: {
    rowId: {
      type: Number,
      required: true
    },

    otuId: {
      type: Number,
      required: true
    }
  },

  data () {
    return {
      isLoading: false
    }
  },

  computed,

  watch: {
    rowId () {
      this.loadMatrixRow(this.rowId)
    }
  },

  created () {
    this.$store.dispatch(ActionNames.RequestUnits)
  },

  methods: {
    loadMatrixRow (matrixRow) {
      this.$store.commit(MutationNames.ResetState)
      this.isLoading = true
      this.$store.dispatch(ActionNames.RequestMatrixRow, matrixRow).then(() => {
        this.isLoading = false
      })
      this.$store.dispatch(ActionNames.RequestDescription, matrixRow)
    },

    destroyAllObservations () {
      this.$store.dispatch(ActionNames.RemoveObservationsRow, this.rowId).then(() => {
        this.loadMatrixRow(this.rowId)
      })
    },

    cloneScorings (args) {
      this.isLoading = true
      this.$store.dispatch(ActionNames.CreateClone, args).finally(() => {
        this.isLoading = false
      })
    },

    copyScorings (args) {
      this.isLoading = true
      this.$store.dispatch(ActionNames.CreateClone, args).then(() => {
        this.loadMatrixRow(this.rowId)
      }).finally(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
