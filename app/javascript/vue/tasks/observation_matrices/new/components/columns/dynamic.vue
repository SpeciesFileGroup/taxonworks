<template>
  <BlockLayout>
    <template #header>
      <h3>Columns</h3>
    </template>
    <template #body>
      <fieldset>
        <legend>Tag/Keyword</legend>
        <SmartSelector
          autocomplete-url="/controlled_vocabulary_terms/autocomplete"
          :autocomplete-params="{ 'type[]': KEYWORD }"
          get-url="/controlled_vocabulary_terms/"
          model="keywords"
          buttons
          inline
          :klass="TAG"
          target="ObservationMatrixColumn"
          button-class="button-submit"
          @selected="create"
        />
      </fieldset>
    </template>
  </BlockLayout>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import { KEYWORD, TAG } from '@/constants'
import SmartSelector from '@/components/ui/SmartSelector'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ObservationTypes from '../../const/types.js'

const store = useStore()

const matrixId = computed(() => store.getters[GetterNames.GetMatrix].id)

function create(item) {
  let data = {
    controlled_vocabulary_term_id: item.id,
    observation_matrix_id: matrixId.value,
    type: ObservationTypes.Column.Tag
  }
  store.dispatch(ActionNames.CreateColumnItem, data)
}
</script>
