<template>
  <div class="field">
    <label>Roles</label>
    <ul class="no_bullets">
      <li
        v-for="(label, key) in roleTypes"
        :key="key">
        <label>
          <input
            type="checkbox"
            :value="key"
            v-model="selected">
          {{ roleTypes[key] }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { People } from 'routes/endpoints'

export default {
  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  computed: {
    selected: {
      get () {
        return this.modelValue
      },
      set (value) {
        this.$emit('update:modelValue', value)
      }
    }
  },

  created () {
    People.roleTypes().then(response => {
      this.roleTypes = response.body
    })
  },

  data () {
    return {
      roleTypes: {}
    }
  }
}
</script>
