<template>
  <modal-component
    :container-style="{
      width: '1000px',
      maxHeight: '90vh',
      overflow: 'scroll'
    }"
    @close="$emit('close')">
    <template #header>
      <h3>{{ descriptor.name }}</h3>
    </template>
    <template #body>
      <div
        class="horizontal-center-content">
        <div
          v-for="depiction in depictions"
          :key="depiction.id">
          <div>
            <img
              :src="depiction.image.alternatives.medium.image_file_url"
              style="max-height: 150px;"
            >
          </div>
          <span v-if="depiction.caption">{{ depiction.caption }}</span>
        </div>
      </div>
      <h3
        v-if="descriptor.description"
        class="horizontal-center-content">
        {{ descriptor.description }}
      </h3>
      <hr v-if="descriptor.description && depictions.find(d => d.caption != null)">
      <template
        v-for="(row, rIndex) in chunkArray(descriptor.characterStates, 3)"
        :key="`${rIndex}-depictions`">
        <div class="wrapper">
          <character-state
            v-for="(characterState, index) in row"
            :key="index"
            :character-state="characterState"
            @select="updateStateChecked(characterState.id, !isStateChecked(characterState.id))"
          />
        </div>
        <div class="wrapper margin-medium-bottom">
          <div
            v-for="(characterState, index) in row"
            :key="index"
          >
            <label>
              <input
                type="checkbox"
                :checked="isStateChecked(characterState.id)"
                @change="updateStateChecked(characterState.id, $event.target.checked)"
              >
              {{ characterState.label }}: {{ characterState.name }}
              {{ characterState.name }} ({{ characterState.number_of_objects }})
            </label>
          </div>
        </div>
      </template>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import CharacterState from './Character'
import { Descriptor } from 'routes/endpoints'
import { chunkArray } from 'helpers/arrays.js'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  components: {
    ModalComponent,
    CharacterState
  },

  props: {
    descriptor: {
      type: Object,
      required: true
    },

    modelValue: {
      type: Object,
      default: () => []
    }
  },

  emits: [
    'update:modelValue',
    'update',
    'close'
  ],

  data () {
    return {
      depictions: [],
      selected: [],
      copy: [],
      observations: []
    }
  },

  created () {
    this.observations = this.$store.getters[GetterNames.GetObservationsFor](this.descriptor.id)

    Descriptor.depictions(this.descriptor.id).then(response => {
      this.depictions = response.body
    })
  },

  methods: {
    isStateChecked (characterStateId) {
      return this.$store.getters[GetterNames.GetCharacterStateChecked]({
        descriptorId: this.descriptor.id,
        characterStateId
      })
    },

    updateStateChecked (characterStateId, isChecked) {
      this.$store.commit(MutationNames.SetCharacterStateChecked, {
        descriptorId: this.descriptor.id,
        characterStateId,
        isChecked
      })
    },

    chunkArray
  }
}
</script>
<style lang="scss" scoped>

.wrapper {
  display: grid;
  grid-template-columns: repeat( 3, minmax(33.33%, 1fr) );
  grid-gap: 10px;
}

</style>
