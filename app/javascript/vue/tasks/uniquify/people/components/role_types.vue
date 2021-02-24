<template>
  <div>
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

import { GetRoleTypes } from '../request/resources'

export default {
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  computed: {
    selected: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    }
  },
  mounted () {
    GetRoleTypes().then(response => {
      this.roleTypes = response.body
    })
  },
  data() {
    return {
      roleTypes: {}
    }
  }
}
</script>
