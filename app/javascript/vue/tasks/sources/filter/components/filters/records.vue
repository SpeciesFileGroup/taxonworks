<template>
  <div>
    <h3>By records with</h3>
    <ul class="no_bullets">
      <li v-for="(item, key) in params">
        <label class="capitalize">
          <input
            :key="key"
            :value="item"
            type="checkbox"
            v-model="params[key]">
          {{ key }}
        </label>
      </li>
    </ul>
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
    params: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  }
}
</script>
