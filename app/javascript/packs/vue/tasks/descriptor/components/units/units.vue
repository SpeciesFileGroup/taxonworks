<template>
  <div>
    <h2>Default units</h2>
    <select class="normal-input">
      <option
        v-for="(label, key) in list"
        :value="key">{{ label }}
      </option>
    </select>
    <button
      class="normal-input button button-submit"
      type="button">Create
    </button>
  </div>
</template>
<script>

import { GetUnits } from '../../request/resources'

export default {
  data() {
    return {
      list: undefined
    }
  },
  mounted() {
    GetUnits().then(response => {
      this.list = response
    })
  },
  methods: {

  }
}
</script>