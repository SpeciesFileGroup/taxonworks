<template>
  <div>
    <h3>Character states</h3>
    <div class="horizontal-left-content align-start">
      <div class="field">
        <label>Label</label><br>
        <input
          class="character-input"
          maxlength="2"
          type="text"
          v-model="characterState.label"
        >
      </div>
      <div class="field separate-left">
        <div class="separate-bottom">
          <label>Name</label><br>
          <input
            type="text"
            v-model="characterState.name"
          >
        </div>
        <template v-if="show">
          <div class="separate-bottom">
            <label>Description name</label><br>
            <input
              type="text"
              v-model="characterState.description_name"
            >
          </div>
          <div>
            <label>Key name</label><br>
            <input
              type="text"
              v-model="characterState.key_name"
            >
          </div>
        </template>
      </div>
      <div class="field separate-left">
        <br>
        <template v-if="characterState.id">
          <button
            :disabled="!validateFields"
            class="normal-input button button-submit"
            @click="updateCharacter"
            type="button"
          >
            Update
          </button>
          <button
            class="button normal-input button-default"
            @click="resetInputs"
          >
            New
          </button>
        </template>
        <button
          v-else
          @click="createCharacter"
          :disabled="!validateFields"
          class="normal-input button button-submit"
          type="button"
        >
          Add
        </button>
        <a
          class="separate-left cursor-pointer"
          @click="show = !show"
        > {{ show ? 'Hide' : 'Show more' }}</a>
      </div>
    </div>
    <ul
      v-if="list.length"
      class="table-entrys-list">
      <draggable
        v-model="list"
        item-key="id"
        @end="onSortable"
      >
        <template #item="{ element, index }">
          <li class="flex-separate middle">
            <span> {{ element.object_tag }} </span>
            <div class="horizontal-left-content middle">
              <span
                class="circle-button btn-edit"
                @click="editCharacter(index)"
              />
              <radial-annotator :global-id="element.global_id" />
              <span
                class="circle-button btn-delete"
                @click="removeCharacter(index)"
              />
            </div>
          </li>
        </template>
      </draggable>
    </ul>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import Draggable from 'vuedraggable'

export default {
  components: {
    Draggable,
    RadialAnnotator
  },

  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: [
    'update:modelValue',
    'save'
  ],

  computed: {
    validateFields () {
      return this.characterState.label && this.characterState.name && this.descriptor.name
    },
    descriptor: {
      get () {
        return this.modelValue
      },
      set () {
        this.$emit('update:modelValue', this.value)
      }
    }
  },

  data () {
    return {
      show: false,
      list: [],
      characterState: this.newCharacter()
    }
  },

  watch: {
    descriptor: {
      handler (newVal, oldVal) {
        if (JSON.stringify(newVal.character_states) !== JSON.stringify(oldVal.character_states)) { this.list = this.sortPosition(newVal.character_states) }
      },
      deep: true
    }
  },

  mounted () {
    if (this.descriptor.hasOwnProperty('character_states')) {
      this.list = this.sortPosition(this.descriptor.character_states)
    }
  },

  methods: {
    createCharacter () {
      this.descriptor.character_states_attributes = [this.characterState]
      this.$emit('save', this.descriptor)
      this.resetInputs()
    },

    newCharacter () {
      return {
        label: undefined,
        name: undefined,
        description_name: undefined,
        key_name: undefined,
        id: undefined
      }
    },

    resetInputs () {
      this.characterState = this.newCharacter()
    },

    removeCharacter (index) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.list[index]._destroy = true
        this.onSortable()
      }
    },

    editCharacter (index) {
      this.characterState.id = this.list[index].id
      this.characterState.label = this.list[index].label
      this.characterState.name = this.list[index].name
      this.characterState.key_name = this.list[index].key_name
      this.characterState.description_name = this.list[index].description_name
    },

    updateCharacter () {
      const index = this.list.findIndex((item) => item.id === this.characterState.id)

      if (index > -1) {
        this.descriptor.character_states_attributes = [this.characterState]
        this.$emit('save', this.descriptor)
      }
      this.resetInputs()
    },

    onSortable () {
      this.updateIndex()
      this.descriptor.character_states_attributes = this.list
      this.$emit('save', this.descriptor)
    },

    updateIndex () {
      this.list.forEach((element, index) => {
        this.list[index].position = (index + 1)
      })
    },

    sortPosition (list) {
      list.sort((a, b) => {
        if (a.position > b.position) {
          return 1
        }
        return -1
      })
      return list
    }
  }
}
</script>
<style scoped>
  .character-input {
    width: 40px !important;
  }
</style>
