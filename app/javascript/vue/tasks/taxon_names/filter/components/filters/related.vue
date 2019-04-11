<template>
  <div>
    <h2>Related</h2>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="checkbox"
            v-model="optionValue.ancestors">
          Include ancestors
        </label>
      </li>
      <li>
        <label>
          <input
            type="checkbox"
            v-model="optionValue.descendants">
          Include descendants
        </label>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      default: undefined
    }
  },
  computed: {
    optionValue: {
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
