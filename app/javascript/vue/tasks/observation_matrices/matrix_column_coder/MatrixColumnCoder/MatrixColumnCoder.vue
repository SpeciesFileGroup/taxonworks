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
        <div class="horizontal-left-content middle">
          <h3
            class="matrix-row-coder__title"
            v-html="descriptor.title"
          />
          <RadialNavigator :global-id="descriptor.globalId" />
        </div>
        <div
          v-if="descriptor.id"
          class="horizontal-right-content middle"
        >
          <OptionUnsecoredRows class="margin-medium-right" />
          <OptionCharacterStateFilter
            v-if="descriptor.type === componentName.Qualitative"
            class="margin-small-right"
          />
          <RowObjectList class="margin-small-right" />
          <CodeColumn
            class="margin-small-right"
            :descriptor="descriptor"
            :column-id="observationColumnId"
          />
          <ObservationRowDestroy />
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
          :index="(index + 1)"
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
import { GetterNames } from '../store/getters/getters'
import componentName from '../helpers/ComponentNames'
import OptionUnsecoredRows from './Option/OptionUnsecoredRows.vue'
import OptionCharacterStateFilter from './Option/OptionCharacterStateFilter.vue'
import ContinuousDescriptor from './ContinuousDescriptor/ContinuousDescriptor.vue'
import FreeTextDescriptor from './SingleObservationDescriptor/FreeText/FreeText.vue'
import PresenceDescriptor from './SingleObservationDescriptor/PresenceDescriptor/PresenceDescriptor.vue'
import SampleDescriptor from './SampleDescriptor/SampleDescriptor.vue'
import QualitativeDescriptor from './QualitativeDescriptor/QualitativeDescriptor.vue'
import MediaDescriptor from './MediaDescriptor/MediaDescriptor.vue'
import Spinner from 'components/spinner'
import NavbarComponent from 'components/layout/NavBar.vue'
import NavigationMatrix from './Navigation/NavigationMatrix.vue'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import RowObjectList from './RowObjects/RowObjects.vue'
import CodeColumn from './CodeColumn/CodeColumn.vue'
import ObservationRowDestroy from './ObservationRow/ObservationRowDestroy.vue'

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
    RowObjectList,
    RadialNavigator,
    OptionUnsecoredRows,
    OptionCharacterStateFilter,
    Spinner,
    CodeColumn,
    ObservationRowDestroy
  },

  props: {
    columnId: {
      type: Number,
      default: undefined
    }
  },

  data () {
    return {
      isLoading: false,
      componentName
    }
  },

  computed: {
    ...mapState({
      descriptor: state => state.descriptor,
      observations: state => state.observations,
      onlyScoredRows: state => state.options.showOnlyUnscoredRows,
      observationColumnId: state => state.observationColumnId
    }),
    rowObjects () {
      return this.$store.getters[GetterNames.GetRowObjects]
    },
  },

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
