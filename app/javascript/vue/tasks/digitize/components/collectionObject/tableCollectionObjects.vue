<template>
  <table class="vue-table">
    <tbody class="list-complete">
      <tr
        v-for="item in collectionObjects"
        class="list-complete-item"
        :class="{ 'highlight': isSelected(item) }">
        <td>{{ item.total }}</td>
        <td>{{ showBiocurations(item) }}</td>
        <td class="horizontal-right-content">
          <radial-annotator :global-id="item.global_id"/>
          <button
            type="button"
            class="button circle-button btn-edit"
            @click="setCO(item)">Select</button>
          <pin-component
            type="CollectionObject"
            :object-id="item.id"/>
          <button
            type="button"
            class="button circle-button btn-delete"
            @click="removeCO(item.id)"/>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>

import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { ActionNames } from '../../store/actions/actions.js'
import RadialAnnotator from '../../../../components/annotator/annotator.vue'
import PinComponent from '../../../../components/pin'

export default {
  components: {
    RadialAnnotator,
    PinComponent
  },
  computed: {
    collectionObjects() {
      return this.$store.getters[GetterNames.GetCollectionObjects]
    },
    collectionObject() {
      return this.$store.getters[GetterNames.GetCollectionObject]
    },
    biocurations() {
      return this.$store.getters[GetterNames.GetBiocurations]
    }
  },
  methods: {
    setCO(value) {
      this.$store.commit(MutationNames.SetCollectionObject, value)
    },
    showBiocurations(co) {
      let list = this.biocurations.filter(item => item.biological_collection_object_id == co.id).map(item => { return item.object_tag })
      return (list.length ? list.join(', ') : 'Specimen')
    },
    removeCO(id) {
      this.$store.dispatch(ActionNames.RemoveCollectionObject, id)
    },
    isSelected(item) {
      return this.collectionObject.id == item.id
    }
  }
}
</script>
<style scoped>
  .highlight {
    background-color: #E3E8E3;
  }
  .vue-table {
    min-width: 400px;
  }
</style>

