<template>
  <transition name="zoomed-view__transition">
    <div
      class="zoomed-view"
      :class="{ 'zoomed-view--unsaved': isUnsaved }"
      v-if="descriptor.isZoomed">

      <button class="zoomed-view__close-button" @click="closeZoom" type="button">Return</button>
      <slot/>
    </div>
  </transition>
</template>

<style src="./ZoomedView.styl" lang="stylus"></style>

<script>
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

export default {
  name: 'ZoomedView',
  props: ['descriptor'],
  computed: {
    isUnsaved: function () {
      return this.$store.getters[GetterNames.IsDescriptorUnsaved](this.$props.descriptor.id)
    }
  },
  methods: {
    closeZoom: function () {
      this.$store.commit(MutationNames.SetDescriptorZoom, {
        descriptorId: this.descriptor.id,
        isZoomed: false
      })
    }
  }
}
</script>
