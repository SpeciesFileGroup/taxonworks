<template>
  <hr>
  <div>
    <description-component />
    <description-diagnosis />
    <description-similar />
  </div>
  <button
    class="button normal-input button-default margin-medium-top"
    type="button"
    @click="loadDescription">
    Reload
  </button>
  <hr>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'

import DescriptionComponent from './Description.vue'
import DescriptionSimilar from './DescriptionSimilar.vue'
import DescriptionDiagnosis from './DescriptionDiagnosis.vue'

export default {
  components: {
    DescriptionComponent,
    DescriptionSimilar,
    DescriptionDiagnosis
  },

  computed: {
    rowId () {
      return this.$store.getters[GetterNames.GetMatrixRow].id
    }
  },

  methods: {
    loadDescription () {
      this.$store.dispatch(ActionNames.RequestDescription, this.rowId)
    }
  }
}
</script>
