<template>
  <div class="qualitative-descriptor">
    <summary-view
      :index="index"
      :descriptor="descriptor">
      <ul>
        <li
          class="horizontal-left-content qualitative-descriptor__descriptor-li"
          v-for="(characterState, index) in descriptor.characterStates">
          <label>
            <input
              type="checkbox"
              :checked="isStateChecked(characterState.id)"
              @change="updateStateChecked(characterState.id, $event)">
            {{ characterState.label }}: {{ characterState.name }}
          </label>
          <template v-if="getObservationFromCharacterId(characterState.id)">
            <radial-annotator :global-id="getObservationFromCharacterId(characterState.id).global_id"/>
          </template>
        </li>
      </ul>
    </summary-view>
  </div>
</template>

<style src="./QualitativeDescriptor.styl" lang="stylus"></style>

<script>
import { ActionNames } from '../../store/actions/actions'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

import summaryView from '../SummaryView/SummaryView.vue'
import RadialAnnotator from 'components/radials/annotator/annotator'

export default {
  name: 'QualitativeDescriptor',
  props: ['descriptor', 'index'],
  created: function () {
    const descriptorId = this.$props.descriptor.id
    const otuId = this.$store.state.taxonId

    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
      .then(_ => this.$store.getters[GetterNames.GetObservationsFor](descriptorId))
      .then(observations => {
        this.observations = observations
      })
  },
  data: function () {
    return {
      observations: []
    }
  },
  methods: {
    isStateChecked (characterStateId) {
      return this.$store.getters[GetterNames.GetCharacterStateChecked]({
        descriptorId: this.$props.descriptor.id,
        characterStateId
      })
    },
    getCharacterStateObservation (characterStateId) {
      const observations = this.$store.getters[GetterNames.GetObservationsFor](this.$props.descriptor.id)
      return observations.find(o => o.characterStateId === characterStateId)
    },
    updateStateChecked (characterStateId, event) {
      this.$store.commit(MutationNames.SetCharacterStateChecked, {
        descriptorId: this.$props.descriptor.id,
        characterStateId,
        isChecked: event.target.checked
      })
    },
    getObservationFromCharacterId(id) {
      return this.observations.find(item => {
        return item.characterStateId == id && item.global_id
      })
    }
  },
  components: {
    summaryView,
    RadialAnnotator
  }
}
</script>
