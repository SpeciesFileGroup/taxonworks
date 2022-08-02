<template>
  <div
    id="matrix-row-coder-app"
    class="matrix-row-coder"
  >
    <spinner
      legend="Loading..."
      full-screen
      :logo-size="{ width: '50px', height: '50px'}"
      v-if="isLoading"
    />
    <NavigationMatrix class="margin-medium-bottom" />
    <navbar-component>
      <div class="flex-separate middle">
        <h3
          class="matrix-row-coder__title"
          v-html="descriptor.title"
        />
        <div class="horizontal-right-content middle">
          <NavigationColumn />
          <RowObjectList class="margin-medium-left" />
        </div>
      </div>
    </navbar-component>

    <ul class="matrix-row-coder__descriptor-list no_bullets">
      <li
        class="matrix-row-coder__descriptor-container"
        v-for="(rowObject, index) in rowObjects"
        :key="rowObject.id"
        :data-row-object-id="rowObject.id"
      >
        <component
          :is="descriptor.componentName"
          :index="(index+1)"
          :descriptor="descriptor"
          :row-object="rowObject"
        />
      </li>
    </ul>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { ActionNames } from '../store/actions/actions'
import ContinuousDescriptor from './ContinuousDescriptor/ContinuousDescriptor.vue'
import FreeTextDescriptor from './SingleObservationDescriptor/FreeText/FreeText.vue'
import PresenceDescriptor from './SingleObservationDescriptor/PresenceDescriptor/PresenceDescriptor.vue'
import SampleDescriptor from './SampleDescriptor/SampleDescriptor.vue'
import QualitativeDescriptor from './QualitativeDescriptor/QualitativeDescriptor.vue'
import MediaDescriptor from './MediaDescriptor/MediaDescriptor.vue'
import Spinner from 'components/spinner'
import NavbarComponent from 'components/layout/NavBar.vue'
import NavigationMatrix from './Navigation/NavigationMatrix.vue'
import NavigationColumn from './Navigation/NavigationColumn.vue'
import RowObjectList from './RowObjects/RowObjects.vue'

const computed = mapState({
  descriptor: state => state.descriptor,
  rowObjects: state => state.rowObjects
})

export default {
  name: 'MatrixColumnCoder',

  components: {
    NavbarComponent,
    ContinuousDescriptor,
    FreeTextDescriptor,
    PresenceDescriptor,
    QualitativeDescriptor,
    SampleDescriptor,
    MediaDescriptor,
    NavigationMatrix,
    NavigationColumn,
    RowObjectList,
    Spinner
  },

  props: {
    columnId: {
      type: Number,
      default: undefined
    }
  },

  data () {
    return {
      isLoading: false
    }
  },

  computed,

  watch: {
    columnId: {
      handler () {
        this.loadMatrixColumn(this.columnId)
      },
      immediate: true
    }
  },

  created () {
    this.$store.dispatch(ActionNames.LoadUnits)
  },

  methods: {
    loadMatrixColumn (columnId) {
      this.isLoading = true
      this.$store.dispatch(ActionNames.LoadColumns, columnId).then(() => {
        this.isLoading = false
      })
    }
  }
}
</script>
