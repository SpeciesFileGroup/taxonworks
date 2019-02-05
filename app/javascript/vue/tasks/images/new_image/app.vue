<template>
  <div id="vue-task-images-new">
    <div class="flex-separate middle">
      <h1>Task: New images</h1>
      <span
        data-icon="reset"
        class="cursor-pointer">Reset
      </span>
    </div>
    <div class="panel content separate-bottom">
      <image-dropzone v-model="images"/>
    </div>
    <div class="separate-top separate-bottom">
      <apply-attributes/>
    </div>
    <div class="separate-top separate-bottom">
      <persons-section/>
    </div>
    <div class="separate-top separate-bottom">
      <depic-some/>
    </div>
  </div>
</template>

<script>

import ImageDropzone from './components/images/imageDropzone'
import ApplyAttributes from './components/applyAttributes'
import PersonsSection from './components/personsSection'
import DepicSome from './components/depicSome'
import { GetterNames } from './store/getters/getters.js'
import { MutationNames } from './store/mutations/mutations.js'

export default {
  components: {
    ImageDropzone,
    ApplyAttributes,
    PersonsSection,
    DepicSome
  },
  computed: {
    images: {
      get() {
        return this.$store.getters[GetterNames.GetImagesCreated]
      },
      set(value) {
        this.$store.commit(MutationNames.SetImagesCreated, value)
      }
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