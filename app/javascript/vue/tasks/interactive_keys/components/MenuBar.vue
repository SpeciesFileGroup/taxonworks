<template>
  <nav-component>
    <div class="flex-separate">
      <div>{{ observationMatrix.object_tag }}</div>
      <div class="middle">
        <button
          v-for="layout in layouts"
          type="button"
          :key="layout"
          :value="layout"
          @click="setLayout(layout)"
          class="button normal-input button-default margin-small-left"
          :class="layout">
          <div class="i3-grid layout-mode-1 grid-icon">
            <div class="descriptors-view grid-item"/>
            <div class="taxa-remaining grid-item"/>
            <div class="taxa-eliminated grid-item"/>
          </div>
        </button>
      </div>
    </div>
  </nav-component>
</template>

<script>

import NavComponent from 'components/navBar'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    NavComponent
  },
  computed: {
    observationMatrix () {
      return this.$store.getters[GetterNames.GetObservationMatrix]
    },
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      layouts: ['layout-mode-1 ', 'layout-mode-2']
    }
  },
  methods: {
    setLayout (layout) {
      this.settings.gridLayout = layout
    }
  }
}
</script>

<style>
</style>
