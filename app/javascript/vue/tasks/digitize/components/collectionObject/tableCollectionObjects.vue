<template>
  <table>
    <tbody>
      <tr v-for="item in collectionObjects">
        <td v-html="item.object_tag"></td>
        <td>
          <button
            type="button"
            @click="setCO(item)">Select</button>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'

export default {
  computed: {
    collectionObjects() {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    }
  },
  methods: {
    setCO(value) {
      this.$store.commit(MutationNames.SetCollectionObject, value)
    }
  }
}
</script>
