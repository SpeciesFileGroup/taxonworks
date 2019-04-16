<template>
  <div>
    <h2>Related</h2>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="checkbox"
            :disabled="!taxonName.length"
            v-model="optionValue">
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
    },
    taxonName: {
      type: String,
      default: ''
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
