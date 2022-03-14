<template>
  <div class="qualitative-descriptor">
    <summary-view
      :index="index"
      :descriptor="descriptor"
      :observations="observations"
      is-qualitative
    >
      <ul>
        <li
          class="horizontal-left-content middle qualitative-descriptor__descriptor-li"
          v-for="characterState in descriptor.characterStates"
          :key="characterState.id"
        >
          <label class="margin-small-right middle">
            <input
              type="checkbox"
              :checked="isStateChecked(characterState.id)"
              @change="updateStateChecked(characterState.id, $event)"
            >
            {{ characterState.label }}: {{ characterState.name }}
          </label>

          <template v-if="getObservationFromCharacterId(characterState.id)">
            <TimeFields
              inline
              :descriptor="descriptor"
              :observation="getCharacterStateObservation(characterState.id)"
            />
            <radial-annotator :global-id="getObservationFromCharacterId(characterState.id).global_id" />
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
import TimeFields from '../Time/TimeFields.vue'

export default {
  name: 'QualitativeDescriptor',

  components: {
    summaryView,
    RadialAnnotator,
    TimeFields
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    index: {
      type: Number,
      required: true
    }
  },

  data () {
    return {
      observations: []
    }
  },

  created () {
    const descriptorId = this.descriptor.id
    const otuId = this.$store.state.taxonId

    this.$store.dispatch(ActionNames.RequestObservations, { descriptorId, otuId })
      .then(_ => this.$store.getters[GetterNames.GetObservationsFor](descriptorId))
      .then(observations => {
        this.observations = observations
      })
  },

  methods: {
    isStateChecked (characterStateId) {
      return this.$store.getters[GetterNames.GetCharacterStateChecked]({
        descriptorId: this.descriptor.id,
        characterStateId
      })
    },

    getCharacterStateObservation (characterStateId) {
      const observations = this.$store.getters[GetterNames.GetObservationsFor](this.descriptor.id)
      return observations.find(o => o.characterStateId === characterStateId)
    },

    updateStateChecked (characterStateId, event) {
      this.$store.commit(MutationNames.SetCharacterStateChecked, {
        descriptorId: this.descriptor.id,
        characterStateId,
        isChecked: event.target.checked
      })
    },

    getObservationFromCharacterId (id) {
      return this.observations.find(item => item.characterStateId === id && item.global_id)
    }
  }
}
</script>
