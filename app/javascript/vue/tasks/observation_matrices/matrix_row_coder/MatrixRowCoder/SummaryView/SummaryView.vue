<template>
  <div
    class="summary-view"
    :class="{ 'summary-view--unsaved': isUnsaved, 'summary-view--saved-at-least-once': savedAtLeastOnce }">
    <DescriptorModal
      v-if="isModalVisible"
      :descriptor="descriptor"
      @close="isModalVisible = false"
    />
    <SpinnerComponent
      legend="Saving changes..."
      :logo-size="{ width: '50px', height: '50px'}"
      v-if="isSaving"
    />
    <div class="flex-separate middle">
      <div class="horizontal-right-content">
        <h2 class="summary-view__title">
          <span
            class="link cursor-pointer"
            @click="isModalVisible = true"
          >
            {{ index }} {{ descriptor.title }}
          </span>
        </h2>
        <RadialAnnotator :global-id="descriptor.globalId" />
        <RadialObject :global-id="descriptor.globalId" />
      </div>
      <p>
        <button
          type="button"
          @click="returnTop"
        >
          Top
        </button>
      </p>
    </div>
    <div>
      <slot />
    </div>
    <SaveCountdown :descriptor="descriptor" />
  </div>
</template>

<style src="./SummaryView.styl" lang="stylus"></style>

<script>
import { GetterNames } from '../../store/getters/getters'
import SpinnerComponent from 'components/spinner.vue'
import SaveCountdown from '../SaveCountdown/SaveCountdown.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'
import RadialObject from 'components/radials/navigation/radial'
import DescriptorModal from '../DepictionModal/DepictionsContainer.vue'

export default {
  name: 'SummaryView',

  components: {
    DescriptorModal,
    SaveCountdown,
    RadialAnnotator,
    RadialObject,
    SpinnerComponent
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    isQualitative: {
      type: Boolean,
      default: false
    },

    index: {
      type: Number,
      required: true
    }
  },

  data: () => ({
    isModalVisible: false
  }),

  computed: {
    isUnsaved () {
      return this.$store.getters[GetterNames.IsDescriptorUnsaved](this.$props.descriptor.id)
    },

    savedAtLeastOnce () {
      return this.$props.descriptor.hasSavedAtLeastOnce
    },

    isSaving () {
      return this.$store.getters[GetterNames.IsDescriptorSaving](this.$props.descriptor.id)
    }
  },

  methods: {
    returnTop () {
      window.scrollTo(0, 0)
    }
  }
}
</script>
