<template>
  <div class="verbatim-layout">
    <h2>Verbatim</h2>
    <draggable 
      v-model="componentsOrder"
      @end="updatePreferences">
      <component
        v-for="componentName in componentsOrder"
        :key="componentName"
        :is="componentName"/>
    </draggable>
  </div>
</template>
<script>

  import Draggable from 'vuedraggable'

  import VerbatimColectors from './verbatim/collectors.vue'
  import VerbatimLabel from './verbatim/label.vue'
  import VerbatimDate from './verbatim/date.vue'
  import VerbatimDatum from './verbatim/datum.vue'
  import VerbatimElevation from './verbatim/elevation.vue'
  import VerbatimGeolocation from './verbatim/geolocationUncertainty.vue'
  import VerbatimHabitat from './verbatim/habitat.vue'
  import VerbatimLatitude from './verbatim/latitude.vue'
  import VerbatimLocality from './verbatim/locality.vue'
  import VerbatimLongitude from './verbatim/longitude.vue'
  import VerbatimMethod from './verbatim/method.vue'

  import { 
    UpdateUserPreferences, 
    GetUserPreferences } from '../../../request/resources.js'

  export default {
    components: {
      Draggable,
      VerbatimColectors,
      VerbatimLabel,
      VerbatimMethod,
      VerbatimDate,
      VerbatimDatum,
      VerbatimElevation,
      VerbatimGeolocation,
      VerbatimHabitat,
      VerbatimLatitude,
      VerbatimLocality,
      VerbatimLongitude
    },
    data() {
      return {
        componentsOrder: [
          'VerbatimColectors', 
          'VerbatimLabel', 
          'VerbatimDate', 
          'VerbatimElevation', 
          'VerbatimGeolocation', 
          'VerbatimHabitat',
          'VerbatimLatitude',
          'VerbatimLongitude',
          'VerbatimLocality',
          'VerbatimMethod'],
        preferences: {}
      }
    },
    mounted() {
      GetUserPreferences().then(response => {
        this.preferences = response
      })
    },
    watch: {
      preferences: {
        handler() {
          this.componentsOrder = this.preferences.layout.tasks.digitize.verbatimOrder
        },
        deep: true
      }
    },
    methods: {
      updatePreferences() {
        let pref = {
          tasks: {
            digitize: {
              verbatimOrder: this.componentsOrder
            }
          }
        }
        UpdateUserPreferences(this.preferences.id, pref).then(response => {
          this.preferences = response.preferences
          this.componentsOrder = response.preferences.layout.tasks.digitize.verbatimOrder
        })
      }
    }
  }
</script>

<style lang="scss">
  .verbatim-layout {
    label {
      display: block;
    }
  }
</style>