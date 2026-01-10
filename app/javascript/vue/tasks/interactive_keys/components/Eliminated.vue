<template>
  <div>
    <spinner-component
      v-if="isLoading"
      legend="Loading..."
    />
    <h2>Eliminated ({{ eliminated.length }})</h2>
    <ul>
      <li
        class="margin-small-bottom"
        v-for="item in eliminated"
        :key="item.object.id"
      >
        <row-component :row="item" />
      </li>
    </ul>
  </div>
</template>

<script>
import { GetterNames } from '../store/getters/getters'
import ExtendResult from './extendResult'
import RowComponent from './Row'
import sides from '../const/filterings.js'

export default {
  mixins: [ExtendResult],

  components: { RowComponent },

  computed: {
    eliminated() {
      if (!this.observationMatrix) return []
      if (this.leadId) {
        const { eliminatedForKey } = this.$store.getters[
          GetterNames.GetObservationObjectIdsByType
        ]([sides.EliminatedForKey], 'Otu')

        return this.observationMatrix.eliminated.filter((item) =>
          eliminatedForKey.includes(item.object.observation_object_id)
        )
      }

      return this.observationMatrix.eliminated
    },

    leadId() {
      return this.$store.getters[GetterNames.GetLeadId]
    }
  },

  data() {
    return {
      showModal: false
    }
  }
}
</script>
