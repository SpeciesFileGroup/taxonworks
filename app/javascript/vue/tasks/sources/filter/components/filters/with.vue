<template>
  <div>
    <h3 class="capitalize">{{ title.replace(/_/g, ' ') }}</h3>
    <ul class="no_bullets context-menu">
      <li
        v-for="option in list"
        :key="option.value"
      >
        <label class="capitalize">
          <input
            :value="option.value"
            :name="name"
            v-model="optionValue"
            type="radio"
          >
          {{ option.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { URLParamsToJSON } from 'helpers/url/parse.js'

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
    },
    values: {
      type: Array,
      default: () => []
    },
    param: {
      type: String,
      default: undefined
    },
    inverted: {
      type: Boolean,
      default: false
    }
  },

  emits: ['update:modelValue'],

  computed: {
    optionValue: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    },

    list () {
      return this.inverted
        ? this.invertedOptions
        : this.options
    }
  },

  data () {
    return {
      options: [
        {
          label: 'Both',
          value: undefined
        },
        {
          label: 'with',
          value: true
        },
        {
          label: 'without',
          value: false
        }
      ],

      invertedOptions: [
        {
          label: 'Both',
          value: undefined
        },
        {
          label: 'with',
          value: false
        },
        {
          label: 'without',
          value: true
        }
      ]
    }
  },

  mounted () {
    if (this.param) {
      const params = URLParamsToJSON(location.href)
      this.optionValue = params[this.param]
    }
  },

  created () {
    if (this.values.length) {
      this.values.forEach((label, index) => {
        this.options[index].label = label
      })
    }
  }
}
</script>
