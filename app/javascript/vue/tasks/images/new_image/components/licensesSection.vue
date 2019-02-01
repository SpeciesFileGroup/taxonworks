<template>
  <div class="panel content">
    <h2>Licenses</h2>
    <ul class="no_bullets">
      <li
        v-for="lic in licenses"
        :key="lic.key">
        <label>
          <input
            name="license"
            :value="lic.key"
            v-model="license"
            type="radio">
          <span v-if="lic.key != null">{{ lic.key }}: </span>{{ lic.label }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script>

import { GetLicenses } from '../request/resources.js'
import { GetterNames } from '../store/getters/getters.js'
import { MutationNames } from '../store/mutations/mutations.js'

export default {
  computed: {
    license: {
      get() {
        return this.$store.getters[GetterNames.GetLicense]
      },
      set(value) {
        this.$store.commit(MutationNames.SetLicense, value)
      }
    }
  },
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
