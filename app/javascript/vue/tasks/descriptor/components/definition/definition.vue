<template>
  <div class="panel basic-information">
    <div class="header">
      <h3>Definition</h3>
    </div>
    <div class="body">
      <div class="horizontal-left-content align-start">
        <div>
          <div class="field">
            <label>Name</label>
            <input
              type="text"
              v-model="processName">
          </div>
          <div class="field">
            <label>Description</label>
            <textarea
              v-model="processDescription"
              rows="5"/>
          </div>
        </div>
        <div
          v-if="show"
          class="separate-left">
          <div class="field separate-bottom">
            <label>Description name</label>
            <input 
              type="text"
              v-model="processDescriptionName">
          </div>
          <div class="field">
            <label>Key name</label>
            <input 
              type="text"
              v-model="processKeyName">
          </div>
        </div>
      </div>
      <div class="horizontal-left-content middle">
        <create-component 
          :descriptor="descriptor"
          @save="$emit('save', descriptor)"/>
        <a
          class="separate-left cursor-pointer"
          @click="show = !show"> {{ show ? 'Hide' : 'Show more' }}</a>
      </div>
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
    },
    processDescriptionName: {
      get() {
        return this.descriptor.description_name
      },
      set(value) {
        this.$emit('onDescriptionNameChange', value)
      }
    },
    processKeyName: {
      get() {
        return this.descriptor.key_name
      },
      set(value) {
        this.$emit('onKeyNameChange', value)
      }
    }
  },
  data() {
    return {
      show: false
    }
  }
}
</script>
<style scoped>
  label {
    display: block;
  }
</style>