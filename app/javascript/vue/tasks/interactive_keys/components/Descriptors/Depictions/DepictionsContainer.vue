<template>
  <modal-component @close="$emit('close')">
    <h3 slot="header">{{ descriptor.name }}</h3>
    <div slot="body">
      <character-state
        v-for="(character, index) in descriptor.states"
        :character-state="character"
      />
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/modal'
import CharacterState from './Character'
import { GetCharacterStateDepictions } from '../../../request/resources.js'

export default {
  components: {
    ModalComponent,
    CharacterState
  },
  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },
  mounted () {
    GetCharacterStateDepictions()
  },
  methods: {

  }
}
</script>
