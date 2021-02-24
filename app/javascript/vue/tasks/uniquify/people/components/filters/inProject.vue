<template>
  <div class="field">
    <h3>Referenced in project</h3>
    <ul class="no_bullets">
      <li
        v-for="(option, index) in options"
        :key="index">
        <label>
          <input
            type="radio"
            v-model="inputValue"
            :value="option.value">
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
      type: Array,
      default: () => []
    }
  },
  computed: {
    inputValue: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  data () {
    return {
      options: [{
        label: 'Any',
        value: []
      },
      {
        label: 'Current',
        value: [document.querySelector('[data-project-id]').getAttribute('data-project-id')]
      }]
    }
  }
}
</script>

<style>

</style>