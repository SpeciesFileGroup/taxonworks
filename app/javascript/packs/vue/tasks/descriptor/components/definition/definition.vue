<template>
  <div>
    <h2>Definition</h2>
    <div class="field">
      <label>Name</label>
      <input
        type="text"
        v-model="processName"/>
    </div>
    <div class="field">
      <label>Description</label>
      <textarea v-model="processDescription"></textarea>
    </div>
  </div>
</template>
<script>
export default {
  props: {
    name: {
      default: undefined
    },
    description: {
      default: undefined
    }
  },
  computed: {
    processName: {
      get() {
        return this.name
      },
      set(value) {
        this.$emit('onNameChange', value)
      }
    },
    processDescription: {
      get() {
        return this.description
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