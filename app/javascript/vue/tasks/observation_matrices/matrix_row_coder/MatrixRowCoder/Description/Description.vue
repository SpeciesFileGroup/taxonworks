<template>
  <div>
    <h2>Description</h2>
    <p>{{ description }}</p>
    <button
      class="button normal-input button-default"
      type="button"
      @click="loadDescription">
      Reload
    </button>
  </div>
</template>

<script>

import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'

export default {
  computed: {
    rowId () {
      return this.$store.getters[GetterNames.GetMatrixRow].id
    },

    description () {
      return this.$store.getters[GetterNames.GetDescription]?.generated_description
    }
  },

  methods: {
    loadDescription () {
      this.$store.dispatch(ActionNames.RequestDescription, this.rowId)
    }
  }
}
</script>
