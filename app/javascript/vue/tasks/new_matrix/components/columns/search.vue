<template>
  <div>
    <div class="flex-wrap">
      <div class="field">
        <autocomplete
          min="2"
          :clear-after="true"
          placeholder="Select a descriptor"
          label="label_html"
          @getItem="createColumnItem($event.id)"
          url="/descriptors/autocomplete"
          param="term"/>
      </div>
    </div>
  </div>
</template>
<script>

import Autocomplete from 'components/autocomplete.vue'

import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import ObservationTypes from '../../const/types.js'

export default {
  components: {
    Autocomplete
  },
  computed: {
    matrix() {
      return this.$store.getters[GetterNames.GetMatrix]
    }
  },
  data () {
    return {
      displayAutocomplete: undefined,
      objectId: undefined
    }
  },
  methods: {
    createColumnItem (id) {
      const data = {
        observation_matrix_id: this.matrix.id,
        descriptor_id: id,
        type: ObservationTypes.Column.Descriptor
      }
      this.$store.dispatch(ActionNames.CreateColumnItem, data)
    }
  }
}
</script>
