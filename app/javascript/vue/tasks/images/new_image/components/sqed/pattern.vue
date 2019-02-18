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
              :key="key"
              name="sqed-pattern"
              @click="setPattern(pattern)"
              :checked="pattern.layout === value.layout"
              type="radio">
            {{ key | humanize }}
          </label>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    value: {
      type: Object,
    },
    patterns: {
      type: Object,
      default: () => { return {} }
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
  filters: {
    humanize: function (value) {
      if (!value) return ''
      value = value.toString().replace(/_/g, ' ')
      return value.charAt(0).toUpperCase() + value.slice(1)
    }
  },
  methods: {
    setPattern(pattern) {
      this.selected = pattern
    }
  }
}
</script>
