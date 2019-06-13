<template>
  <div>
    <h2>Children</h2>
    <ul class="no_bullets">
      <li
        v-for="option in options">
        <label>
          <input
            :value="option.value"
            v-model="optionValue"
            type="radio">
          {{ option.label }}
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
  data() {
    return {
      options: [
        {
          label: 'With/out children',
          value: undefined 
        },
        { 
          label: 'With children',
          value: false
        },
        { 
          label: 'Without children',
          value: true
        }
      ]
    }
  }
}
</script>