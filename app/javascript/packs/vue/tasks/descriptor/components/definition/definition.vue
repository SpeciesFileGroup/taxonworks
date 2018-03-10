<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Definition</h3>
    </div>
    <div class="body">
      <div class="field">
        <label>Name</label>
        <input
          type="text"
          v-model="processName"/>
      </div>
      <div class="field">
        <label>Description</label>
        <textarea
          v-model="processDescription"
          rows="5"></textarea>
      </div>
      <create-component 
        :descriptor="descriptor"
        @save="$emit('save', descriptor)"/>
    </div>
  </div>
</template>
<script>

import CreateComponent from '../save/save.vue'

export default {
  components: {
    CreateComponent
  },
  props: {
    descriptor: {
      type: Object,
      required: true
    },
  },
  computed: {
    processName: {
      get() {
        return this.descriptor.name
      },
      set(value) {
        this.$emit('onNameChange', value)
      }
    },
    processDescription: {
      get() {
        return this.descriptor.description
      },
      set(value) {
        this.$emit('onDescriptionChange', value)
      }
    }
  },
}
</script>
<style scoped>
  label {
    display: block;
  }
</style>