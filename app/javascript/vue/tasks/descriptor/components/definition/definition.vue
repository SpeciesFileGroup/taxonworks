<template>
  <div class="horizontal-left-content align-start">
    <div>
      <div class="field">
        <label>Name</label>
        <input
          type="text"
          v-model="descriptor.name"
        >
      </div>
      <div class="field">
        <label>Description</label>
        <textarea
          v-model="descriptor.description"
          rows="5"
        />
      </div>
      <a
        class="cursor-pointer"
        @click="show = !show"
      > {{ show ? 'Hide' : 'Show more' }}</a>
    </div>
    <div
      v-if="show"
      class="separate-left"
    >
      <div class="field separate-bottom">
        <label>Short name</label>
        <div>
          <input
            type="text"
            v-model="descriptor.short_name"
          >
          <span
            v-if="!validateShortName"
            class="warning"
          >Should not be longer than 6 characters
          </span>
        </div>
      </div>
      <div class="field separate-bottom">
        <label>Description name</label>
        <input
          type="text"
          v-model="descriptor.description_name"
        >
      </div>
      <div class="field">
        <label>Key name</label>
        <input
          type="text"
          v-model="descriptor.key_name"
        >
      </div>
      <div class="field">
        <label>Weight</label>
        <input
          type="number"
          v-model="descriptor.weight"
        >
      </div>
    </div>
  </div>
</template>
<script>

export default {
  props: {
    modelValue: {
      type: Object,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    validateShortName () {
      return this.descriptor.short_name ? this.descriptor.short_name.length <= 6 : true
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
