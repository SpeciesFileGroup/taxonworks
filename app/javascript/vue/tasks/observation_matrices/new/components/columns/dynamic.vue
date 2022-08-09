<template>
  <div class="panel basic-information separate-top">
    <div class="header">
      <h3>Columns</h3>
    </div>
    <div class="body">
      <fieldset>
        <legend>Tag/Keyword</legend>
        <smart-selector
          autocomplete-url="/controlled_vocabulary_terms/autocomplete"
          :autocomplete-params="{'type[]' : 'Keyword'}"
          get-url="/controlled_vocabulary_terms/"
          model="keywords"
          buttons
          inline
          klass="Tag"
          target="ObservationMatrixColumn"
          button-class="button-submit"
          @selected="create"/>
      </fieldset>
    </div>
  </div>
</template>
<script>

import SmartSelector from 'components/ui/SmartSelector'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import ObservationTypes from '../../const/types.js'

export default {
  components: {
    SmartSelector
  },
  computed: {
    matrixId () {
      return this.$store.getters[GetterNames.GetMatrix].id
    }
  },
  data() {
    return {

    }
  },
  methods: {
    create (item) {
      let data = {
        controlled_vocabulary_term_id: item.id,
        observation_matrix_id: this.matrixId,
        type: ObservationTypes.Column.Tag
      }
      this.$store.dispatch(ActionNames.CreateColumnItem, data)
    }
  }
}
</script>
