<template>
  <div>
    <h3 class="capitalize">{{ title.replace(/_/g, ' ') }}</h3>
    <ul class="no_bullets context-menu">
      <li
        v-for="option in options">
        <label class="capitalize">
          <input
            :value="option.value"
            :name="name"
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
    name: {
      type: String,
      default: () => Math.random().toString(36).substr(2, 5)
    },

    title: {
      type: String,
      required: true
    },

    modelValue: {
      type: Boolean,
      default: undefined
    }
  },

  computed: {
    optionValue: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  data () {
    return {
      options: [
        {
          label: 'Absent',
          value: false
        },
        {
          label: 'Present',
          value: true
        },
        {
          label: 'Both',
          value: undefined
        },
      ]
    }
  }
}
</script>
