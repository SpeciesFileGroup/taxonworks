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
          <button
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
            v-for="(label, index) in list">
            <span> {{ label.object_tag }} </span>
            <span
              class="circle-button btn-delete"
              @click="removeCharacter(index)"/>
          </li>
        </draggable>
      </ul>
    </div>
  </div>
</template>
<script>

import DisplayList from '../../../../components/displayList.vue'
import Draggable from 'vuedraggable'

export default {
  components: {
    DisplayList,
    Draggable
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
    },
    removeCharacter(index) {
      this.list[index]['_destroy'] = true
      this.onSortable()
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