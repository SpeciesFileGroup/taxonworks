<template>
  <div style="max-height: 450px;">
    <ul class="no_bullets">
      <li v-for="level in levels">
        <label>
          <input
            v-model="selected"
            :value="level"
            type="checkbox">
          {{ level }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Array,
      default: () => []
    },

    levels: {
      type: Array,
      default: () => []
    }
  },

  computed: {
    selected: {
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
