<template>
  <div class="panel content">
    <h2>Licenses</h2>
    <ul class="no_bullets">
      <li
        v-for="license in licenses"
        :key="license.key">
        <label>
          <input
            name="license"
            :value="license.key"
            type="radio">
          <span v-if="license.key != null">{{ license.key }}: </span>{{ license.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetLicenses } from '../request/resources.js'

export default {
  data() {
    return {
      licenses: []
    }
  },
  mounted() {
    GetLicenses().then(response => {
      this.licenses = Object.keys(response.body).map((key) => {
        let license = response.body[key]
        return { 
          key: key,
          label: license
        }
      })
      this.licenses.push({
        label: '-- None --',
        key: null
      })
    })
  }
}
</script>

<style>

</style>
