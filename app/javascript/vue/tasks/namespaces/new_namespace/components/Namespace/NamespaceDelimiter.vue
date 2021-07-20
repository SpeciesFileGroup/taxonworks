<template>
  <div class="field">
    <label>Delimiter</label>
    <p>preview: {{ getDelimiterPreview() }}</p>
    <ul class="no_bullets">
      <li
        v-for="(value, key) in options"
        :key="value">
        <label>
          <input
            type="radio"
            :value="value"
            v-model="delimiter">
          {{ key }}
        </label>
      </li>
      <li>
        <label>
          <input
            type="radio"
            :value="undefined"
            :checked="isCustomDelimiter"
            @click="delimiter = undefined"
          >
          Custom character
        </label>
      </li>
    </ul>
  </div>
  <div
    v-if="isCustomDelimiter"
    class="field label-above">
    <label>Custom character</label>
    <input
      type="text"
      maxlength="1"
      v-model="delimiter">
  </div>
</template>

<script>

import { computed } from 'vue'

const options = {
  SingleWhitespace: '',
  None: 'NONE'
}

export default {
  props: {
    modelValue: {
      type: String,
      default: undefined
    }
  },

  emits: ['update:modelValue'],

  setup (props, { emit }) {
    const isCustomDelimiter = computed(() => !Object.values(options).includes(delimiter.value) || delimiter.value === undefined)
    const delimiter = computed({
      get () {
        return props.modelValue
      },
      set (value) {
        emit('update:modelValue', value)
      }
    })

    const getDelimiterPreview = () => {
      const shortName = props.shortName || '<short_name>'

      if (delimiter.value === options.SingleWhitespace) {
        return `${shortName} 123`
      }
      if (delimiter.value === options.None) {
        return `${shortName}123`
      } else {
        return `${shortName}${delimiter.value || ''}123`
      }
    }

    return {
      getDelimiterPreview,
      isCustomDelimiter,
      delimiter,
      options
    }
  }
}
</script>
