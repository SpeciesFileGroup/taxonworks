<template>
  <div class="qualitative-descriptor">
    <summary-view :descriptor="descriptor">
      <ul>
        <li
          class="horizontal-left-content"
          v-for="characterState in descriptor.characterStates">
          <label>
            <input
              type="checkbox"
              :checked="isStateChecked(characterState.id)"
              @change="updateStateChecked(characterState.id, $event)" >

            {{ characterState.label }}: {{ characterState.name }}
          </label>
          <radial-annotator :global-id="characterState.globalId"/>
        </li>
      </ul>
    </summary-view>

    <zoomed-view :descriptor="descriptor">
      <h2 class="qualitative-descriptor__descriptor-title horizontal-left-content">
        {{ descriptor.title }}
        <radial-annotator :global-id="descriptor.globalId"/>
      </h2>
      <div class="qualitative-descriptor__character-state-list">
        <div
          class="qualitative-descriptor__character-state"
          v-for="characterState in descriptor.characterStates">

          <div class="qualitative-descriptor__character-state-details horizontal-left-content">
            <label>
              <input
                type="checkbox"
                :checked="isStateChecked(characterState.id)"
                @change="updateStateChecked(characterState.id, $event)" >

              {{ characterState.label }}: {{ characterState.name }}
            </label>
            <radial-annotator :global-id="characterState.globalId"/>
          </div>
        </div>
      </div>
    </zoomed-view>
  </div>
</template>

<style src="./QualitativeDescriptor.styl" lang="stylus"></style>

<script>
import { ActionNames } from '../../store/actions/actions'
import { MutationNames } from '../../store/mutations/mutations'
import { GetterNames } from '../../store/getters/getters'

import summaryView from '../SummaryView/SummaryView.vue'
import zoomedView from '../ZoomedView/ZoomedView.vue'
import RadialAnnotator from '../../../components/annotator/annotator'

import descriptorDetails from '../DescriptorDetails/DescriptorDetails.vue'

export default {
  name: 'QualitativeDescriptor',
  props: ['descriptor'],
  created: function () {
    const descriptorId = this.$props.descriptor.id
    const otuId = this.$store.state.taxonId
    // this.$store.dispatch(ActionNames.RequestDescriptorDepictions, descriptorId);
    // this.$store.dispatch(ActionNames.RequestDescriptorNotes, descriptorId);
    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
      .then(_ => this.$store.getters[GetterNames.GetObservationsFor](descriptorId))
      .then(observations => {
        this.observations = observations
        this.observations.forEach(observation => {
          if (observation.id) {
            //                            this.$store.dispatch(ActionNames.RequestObservationCitations, observation.id);
            //                            this.$store.dispatch(ActionNames.RequestObservationConfidences, observation.id);
            //                            this.$store.dispatch(ActionNames.RequestObservationDepictions, observation.id);
            //                            this.$store.dispatch(ActionNames.RequestObservationNotes, observation.id);
          }
        })
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
    }
  },
  components: {
    summaryView,
    zoomedView,
    descriptorDetails,
    RadialAnnotator
  }
}
</script>
