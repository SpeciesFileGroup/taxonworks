<template>
  <modal-component
    @close="closeAndSave"
    :containerStyle="{ 
      width: '700px',
      'maxHeight': '90vh',
      overflow: 'scroll' }">
    <h3 slot="header">{{ descriptor.name }}</h3>
    <div slot="body">
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
      <template v-for="(row, rIndex) in chunkArray(descriptor.states, 3)">
        <div
          class="wrapper"
          :key="`${rIndex}-depictions`">
          <character-state
            v-for="(characterState, index) in row"
            v-model="selected"
            :character-state="characterState"
          />
        </div>
        <div
          :key="`${rIndex}-label`"
          class="wrapper margin-medium-bottom">
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
      <div slot="footer">
        <hr>
        <button
          type="button"
          class="button normal-input button-default"
          @click="closeAndSave">
          Apply
        </button>
      </div>
    </div>
  </modal-component>
</template>

<script>

import ModalComponent from 'components/modal'
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
    value: {
      type: Object,
      default: () => []
    }
  },
  computed: {
    filter: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      depictions: [],
      selected: [],
      copy: []
    }
  },
  created () {
    const data = this.value[this.descriptor.id]
    this.selected = data ? Array.isArray(data) ? data.slice(0) : [data] : []
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
