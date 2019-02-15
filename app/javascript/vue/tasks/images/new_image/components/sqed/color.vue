<template>
  <div>
    <h3>Color</h3>
    <ul class="no_bullets">
      <li
        v-for="color in colors"
        :key="color">
        <label class="capitalize">
          <input
            type="radio"
            name="sqed-color"
            :value="color"
            v-model="selected">
          {{ color }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: String
    },
    colors: {
      type: Array,
      default: () => { return [] }
    }
  },
  computed: {
    selected: {
      get() {
        return this.value
      },
      set(value) {
        this.$emit('input', value)
      }
    }
  },
}
</script>
