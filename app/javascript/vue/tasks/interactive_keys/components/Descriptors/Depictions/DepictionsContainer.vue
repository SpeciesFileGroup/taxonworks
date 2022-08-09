<template>
  <modal-component
    @close="closeAndSave"
    :container-style="{
      width: '1000px',
      maxHeight: '90vh',
      overflow: 'scroll'
    }">
    <template #header>
      <h3>{{ descriptor.name }}</h3>
    </template>
    <template #body>
      <button
        type="button"
        class="button normal-input button-default"
        @click="closeAndSave">
        Apply
      </button>
      <hr>
      <div
        class="horizontal-center-content">
        <div
          v-for="depiction in depictions"
          :key="depiction.id">
          <div>
            <img
              :src="depiction.image.alternatives.medium.image_file_url"
              style="max-height: 150px;"/>
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
      <div v-if="descriptor.states">
        <template
          v-for="(row, rIndex) in chunkArray(descriptor.states, 3)"
          :key="`${rIndex}-depictions`">
          <div class="wrapper">
            <character-state
              v-for="(characterState, index) in row"
              :key="index"
              v-model="selected"
              :character-state="characterState"
            />
          </div>
          <div class="wrapper margin-medium-bottom">
            <div
              v-for="(characterState, index) in row"
              :key="index">
              <label>
                <input
                  type="checkbox"
                  :value="characterState.id"
                  v-model="selected">
                <span v-if="characterState.status === 'useless'">-</span> {{ characterState.name }} ({{ characterState.number_of_objects }})
              </label>
            </div>
          </div>
        </template>
      </div>
    </template>
    <template #footer>
      <hr>
      <button
        type="button"
        class="button normal-input button-default"
        @click="closeAndSave">
        Apply
      </button>
    </template>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import CharacterState from './Character'
import { GetDescriptorDepictions } from '../../../request/resources.js'
import { chunkArray } from 'helpers/arrays.js'

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

    characters: {
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
      copy: []
    }
  },

  created () {
    const characterId = this.characters[this.descriptor.id]

    this.selected = characterId ? Array.isArray(characterId) ? characterId.slice(0) : [characterId] : []
    this.copy = this.selected.slice()

    GetDescriptorDepictions(this.descriptor.id).then(response => {
      this.depictions = response.body
    })
  },

  methods: {
    closeAndSave () {
      if (JSON.stringify(this.copy) !== JSON.stringify(this.selected)) {
        this.$emit('update', this.selected)
      }
      this.$emit('close')
    },

    chunkArray: chunkArray
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
