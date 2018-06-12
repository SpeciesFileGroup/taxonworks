<template>
  <div>
    <p>Select</p>
    <div class="flex-wrap">
      <div class="field">
        <autocomplete
          min="2"
          :display="displayAutocomplete"
          :placeholder="`Select a descriptor`"
          label="label"
          @getItem="setResult"
          url="/descriptors/autocomplete"
          param="term"/>
      </div>
    </div>
    <button
      :disabled="!objectId"
      class="normal-input button button-submit"
      type="button"
      @click="createColumnItem">Create
    </button>
  </div>
</template>
<script>

import Autocomplete from '../../../../components/autocomplete.vue'

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'

export default {
  components: {
    Autocomplete
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    }
  },
  data() {
    return {
      displayAutocomplete: undefined,
      objectId: undefined,
    }
  },
  methods: {
    createColumnItem() {
      let data = {
        observation_matrix_id: this.matrix.id,
        descriptor_id: this.objectId,
        type: 'ObservationMatrixColumnItem::SingleDescriptor'
      }
      this.displayAutocomplete = undefined
      this.objectId = undefined
      this.$store.dispatch(ActionNames.CreateColumnItem, data)
    },
    setResult(descriptor) {
      this.objectId = descriptor.id
      this.displayAutocomplete = descriptor.label
    }
  }
}
</script>