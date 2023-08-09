<template>
  <div>
    <h3>Pattern</h3>
    <div>
      <ul class="no_bullets">
        <li
          v-for="(pattern, key) in patterns"
          :key="key">
          <label>
            <input
              name="sqed-pattern"
              @click="setPattern(pattern)"
              :checked="pattern.layout === modelValue.layout"
              type="radio">
            {{ humanize(key) }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    modelValue: {
      type: Object
    },

    patterns: {
      type: Object,
      default: () => ({})
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  methods: {
    setPattern (pattern) {
      this.selected = pattern
    },

    humanize (value) {
      if (!value) return ''
      value = value.toString().replace(/_/g, ' ')
      return value.charAt(0).toUpperCase() + value.slice(1)
    }
  }
}
</script>
