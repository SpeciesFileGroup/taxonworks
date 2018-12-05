<template>
  <div 
    v-if="isOtu"
    class="horizontal-left-content">
    Copy from OTU:
    <autocomplete
      class="separate-left separate-right"
      url="/otus/autocomplete"
      min="2"
      param="term"
      label="label_html"
      display="label"
      @getItem="otuSelectedGID = $event.gid"/>
    <button
      type="button"
      :disabled="!otuSelectedGID"
      @click="cloneScorings"
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
    isOtu() {
      return this.$store.getters[GetterNames.GetMatrixRow] && this.$store.getters[GetterNames.GetMatrixRow].row_object.base_class == 'Otu'
    },
    rowGlobalId() {
      return this.$store.getters[GetterNames.GetMatrixRow].row_object.global_id
    }
  },
  data() {
    return {
      otuSelectedGID: undefined
    }
  },
  methods: {
    cloneScorings() {
      this.$store.dispatch(ActionNames.CreateClone, {
        old_global_id: this.rowGlobalId,
        new_global_id: this.otuSelectedGID
      }).then(() => {
        this.otuSelectedGID = undefined
        this.$emit('create', true)
      })
    }
  }
}
</script>