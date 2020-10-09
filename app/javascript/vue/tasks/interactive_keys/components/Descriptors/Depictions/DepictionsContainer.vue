<template>
  <modal-component
    @close="$emit('close')"
    :containerStyle="{ width: '700px' }">
    <h3 slot="header">{{ descriptor.name }}</h3>
    <div slot="body">
      <div
        class="wrapper">
        <character-state
          v-for="(character, index) in descriptor.states"
          :key="index"
          v-model="selected[descriptor.id]"
          :character-state="character"
        />
      </div>
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/modal'
import CharacterState from './Character'
import { GetCharacterStateDepictions } from '../../../request/resources.js'
import ExtendDescriptor from '../shared.js'

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
    value: {
      type: Object,
      default: () => []
    }
  },
  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  mounted () {
    console.log(this.descriptor.states.chunk(3))
  },
  methods: {

  }
}
</script>
<style scoped>

.wrapper {
  display: grid;
  grid-template-columns: repeat( 3, minmax(33.33%, 1fr) );
  grid-gap: 10px;
  grid-auto-rows: minmax(100px, auto);
}

</style>