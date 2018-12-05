<template>
  <div class="horizontal-left-content">
    Copy from OTU:
    <autocomplete
      class="separate-left separate-right"
      url="/otus/autocomplete"
      min="2"
      param="term"
      label="label_html"
      display="label"
      @getItem="cloneScorings($event.gid)"/>
    <button
      type="button"
      class="button normal-input button-submit">Clone</button>
  </div>
</template>

<script>

import Autocomplete from 'components/autocomplete.vue'
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    Autocomplete
  },
  computed: {
    rowGlobalId() {
      return this.$store.getters[GetterNames.GetMatrixRow].row_object.global_id
    }
  },
  methods: {
    cloneScorings(newGlobalId) {
      this.$http.post('/tasks/observation_matrices/observation_matrix_hub/copy_observations.json', {
        old_global_id: this.rowGlobalId,
        new_global_id: newGlobalId
      })
      //this.$store.dispatch(ActionNames.CreateClone, {
//        old_global_id: this.rowGlobalId,
 //       new_global_id: newGlobalId
  //    })
    }
  }
}
</script>