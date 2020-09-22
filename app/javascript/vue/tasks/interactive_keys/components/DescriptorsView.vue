<template>
  <div>
    <ol>
      <li
        v-for="descriptor in descriptors"
        :id="descriptor.id">
        <span v-html="descriptor.name"/><br>
        <select>
          <option v-for="state in descriptor.states">
            {{ state.name }}
          </option>
        </select>
      </li>
    </ol>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'

export default {
  computed: {
    descriptors () {
      return this.$store.getters[GetterNames.GetObservationMatrix] ? this.$store.getters[GetterNames.GetObservationMatrix].list_of_descriptors : []
    }
  }
}
</script>
