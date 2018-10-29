<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Character states</h3>
    </div>
    <div class="body">
      <div class="horizontal-left-content">
        <div class="field">
          <label>Label</label>
          <input
            class="character-input"
            maxlength="2"
            type="text"
            v-model="label"/>
        </div>
        <div class="field separate-left">
          <label>Name</label>
          <input 
            type="text"
            v-model="name"/>
        </div>
        <div class="field separate-left">
          <template v-if="id">
            <button
              :disabled="!validateFields"
              class="normal-input button button-submit"
              @click="updateCharacter"
              type="button">Update</button>
            <button
              class="button normal-input button-default"
              @click="resetInputs">New</button>
          </template>
          <button
            v-else
            @click="createCharacter"
            :disabled="!validateFields"
            class="normal-input button button-submit"
            type="button">Create</button>
        </div>
      </div>
      <ul class="table-entrys-list">
        <draggable
          v-model="list"
          @end="onSortable">
          <li
            class="flex-separate middle"
            v-for="(character, index) in list">
            <span> {{ character.object_tag }} </span>
            <div class="horizontal-left-content middle">
              <span
                class="circle-button btn-edit"
                @click="editCharacter(index)"/>
              <radial-annotator :global-id="character.global_id"/>
              <span
                class="circle-button btn-delete"
                @click="removeCharacter(index)"/>
            </div>
          </li>
        </draggable>
      </ul>
    </div>
  </div>
</template>
<script>

import RadialAnnotator from '../../../../components/annotator/annotator.vue'
import Draggable from 'vuedraggable'

export default {
  components: {
    Draggable,
    RadialAnnotator
  },
  props: {
    descriptor: {
      type: Object,
      required: true
    }
  },
  computed: {
    validateFields() {
      return this.descriptor['id'] && this.label && this.name
    }
  },
  data() {
    return {
      label: undefined,
      name: undefined,
      id: undefined,
      list: []
    }
  },
  watch: {
    descriptor: {
      handler(newVal, oldVal) {
        if(JSON.stringify(newVal.character_states) != JSON.stringify(oldVal.character_states))
          this.list = this.sortPosition(newVal.character_states)
      },
      deep: true,
    }
  },
  mounted() {
    if(this.descriptor.hasOwnProperty('character_states'))
      this.list = this.sortPosition(this.descriptor.character_states)
  },
  methods: {
    createCharacter() {
      let newDescriptor = this.descriptor
      newDescriptor['character_states_attributes'] = [{
        descriptor_id: this.descriptor.id,
        name: this.name,
        label: this.label,
      }]
      this.$emit('save', newDescriptor)
      this.resetInputs()
    },
    resetInputs() {
      this.id = undefined,
      this.label = undefined,
      this.name = undefined
    },
    removeCharacter(index) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.list[index]['_destroy'] = true
        this.onSortable()
      }
    },
    editCharacter(index) {
      this.id = this.list[index].id
      this.label = this.list[index].label
      this.name = this.list[index].name
    },
    updateCharacter() {
      let index = this.list.findIndex((item) => {
        return item.id == this.id
      })
      if(index > -1) {
        let newDescriptor = this.descriptor
        this.list[index].label = this.label
        this.list[index].name = this.name
        newDescriptor['character_states_attributes'] = this.list
        this.$emit('save', newDescriptor)
      }
      this.resetInputs()
    },
    onSortable() {
      this.updateIndex()
      let newDescriptor = this.descriptor
      newDescriptor['character_states_attributes'] = this.list
      this.$emit('save', newDescriptor)
    },
    updateIndex() {
      var that = this
      this.list.forEach(function (element, index) {
        that.list[index].position = (index + 1)
      })
    },
    sortPosition(list) {
      list.sort((a, b) => {
        if (a.position > b.position) {
          return 1
        }
        return -1
      })
      return list
    },
  }
}
</script>
<style scoped>
  .character-input {
    width: 40px !important;
  }
</style>