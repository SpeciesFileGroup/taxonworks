<template>
  <div id="vue-task-images-new">
    <spinner-component
      :full-screen="true"
      :legend="'Saving...'"
      :logo-size="{ width: '100px', height: '100px'}"
      v-if="isSaving"
    />
    <div class="flex-separate middle">
      <h1>Task: New images</h1>
      <span
        data-icon="reset"
        class="cursor-pointer"
        @click="resetStore"
      >Reset
      </span>
    </div>
    <div class="panel content separate-bottom">
      <image-dropzone
        v-model="images"
        @delete="removeImage"
        @on-clear="clearDataCreated"
      />
    </div>
    <div class="separate-top separate-bottom">
      <apply-attributes />
    </div>
    <div class="separate-top separate-bottom">
      <persons-section />
    </div>
    <div class="separate-top separate-bottom">
      <div class="flexbox separate-bottom">
        <pixels-unit class="margin-medium-right" />
        <depic-some class="panel-section separate-right" />
        <depiction-component class="panel-section separate-left separate-right" />
        <panel-tag class="panel-section separate-left" />
      </div>
    </div>
    <div class="separate-top separate-bottom">
      <sqed-component />
    </div>
  </div>
</template>

<script>

import SpinnerComponent from 'components/spinner'
import ImageDropzone from './components/images/imageDropzone'
import ApplyAttributes from './components/applyAttributes'
import PersonsSection from './components/personsSection'
import DepicSome from './components/depicSome'
import SqedComponent from './components/sqed/sqed'
import DepictionComponent from './components/depiction'
import PixelsUnit from './components/pixelsUnit.vue'
import PanelTag from './components/Panel/PanelTags.vue'
import { GetterNames } from './store/getters/getters.js'
import { MutationNames } from './store/mutations/mutations.js'
import { ActionNames } from './store/actions/actions.js'

export default {
  components: {
    ImageDropzone,
    ApplyAttributes,
    PersonsSection,
    DepicSome,
    SpinnerComponent,
    SqedComponent,
    DepictionComponent,
    PixelsUnit,
    PanelTag
  },
  computed: {
    images: {
      get() {
        return this.$store.getters[GetterNames.GetImagesCreated]
      },
      set(value) {
        this.$store.commit(MutationNames.SetImagesCreated, value)
      }
    },
    isSaving() {
      return this.$store.getters[GetterNames.GetSettings].saving
    }
  },
  methods: {
    resetStore() {
      this.$store.dispatch(ActionNames.ResetStore)
    },
    clearDataCreated() {
      this.$store.commit(MutationNames.SetDepictions, [])
      this.$store.commit(MutationNames.SetAttributionsCreated, [])
    },
    removeImage(image) {
      this.$store.dispatch(ActionNames.RemoveImage, image)
    }
  }
}
</script>

<style lang="scss">
  #vue-task-images-new {
    .panel-section {
      flex-grow: 1;
      flex-shrink: 1;
      flex-basis: 0;
    }
  }
</style>