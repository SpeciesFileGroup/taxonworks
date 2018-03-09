<template>
  <div>
    <h2>Character states</h2>
    <div class="horizontal-left-content">
      <div class="field">
        <label>Label</label>
        <input
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
    <display-list
      :list="descriptor['character_states']"
      label="object_tag"/>
  </div>
</template>
<script>
import DisplayList from '../../../../components/displayList.vue'
export default {
  components: {
    DisplayList
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
      name: undefined
    }
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
    }
  }
}
</script>