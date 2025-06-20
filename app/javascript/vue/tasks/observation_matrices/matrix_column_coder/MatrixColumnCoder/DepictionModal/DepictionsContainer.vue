<template>
  <modal-component
    :container-style="{
      width: '1000px',
      maxHeight: '90vh',
      overflow: 'scroll'
    }"
    @close="$emit('close')"
  >
    <template #header>
      <h3>{{ descriptor.title }}</h3>
    </template>
    <template #body>
      <div class="horizontal-center-content">
        <div
          v-for="depiction in depictions"
          :key="depiction.id"
        >
          <div>
            <img
              :src="depiction.image.alternatives.medium.image_file_url"
              style="max-height: 150px"
            />
          </div>
          <span v-if="depiction.caption">{{ depiction.caption }}</span>
        </div>
      </div>
      <h3
        v-if="descriptor.description"
        class="horizontal-center-content"
      >
        {{ descriptor.description }}
      </h3>
      <hr
        v-if="
          descriptor.description && depictions.find((d) => d.caption != null)
        "
        class="divisor"
      />
      <div v-if="descriptor.characterStates">
        <template
          v-for="(row, rIndex) in chunkArray(descriptor.characterStates, 3)"
          :key="`${rIndex}-depictions`"
        >
          <div class="wrapper">
            <character-state
              v-for="(characterState, index) in row"
              :key="index"
              :character-state="characterState"
              @select="
                updateStateChecked(
                  characterState.id,
                  !isStateChecked(characterState.id)
                )
              "
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
                  @change="
                    updateStateChecked(characterState.id, $event.target.checked)
                  "
                />
                {{ characterState.label }}: {{ characterState.name }}
              </label>
            </div>
          </div>
        </template>
      </div>
    </template>
  </modal-component>
</template>

<script>
import ModalComponent from '@/components/ui/Modal'
import CharacterState from './Character'
import { Depiction } from '@/routes/endpoints'
import { chunkArray } from '@/helpers/arrays.js'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { DESCRIPTOR } from '@/constants'

export default {
  components: {
    ModalComponent,
    CharacterState
  },

  props: {
    rowObject: {
      type: Object,
      required: true
    }
  },

  computed: {
    descriptor() {
      return this.$store.getters[GetterNames.GetDescriptor]
    }
  },

  emits: ['update', 'close'],

  data() {
    return {
      depictions: []
    }
  },

  created() {
    Depiction.where({
      depiction_object_id: this.descriptor.id,
      depiction_object_type: DESCRIPTOR
    }).then((response) => {
      this.depictions = response.body
    })
  },

  methods: {
    isStateChecked(characterStateId) {
      return this.$store.getters[GetterNames.GetCharacterStateChecked]({
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type,
        characterStateId
      })
    },

    updateStateChecked(characterStateId, isChecked) {
      this.$store.commit(MutationNames.SetCharacterStateChecked, {
        rowObjectId: this.rowObject.id,
        rowObjectType: this.rowObject.type,
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
  grid-template-columns: repeat(3, minmax(33.33%, 1fr));
  grid-gap: 10px;
}
</style>
