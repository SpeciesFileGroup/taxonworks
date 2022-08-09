<template>
  <table class="full_width">
    <thead>
      <tr>
        <th>institutionCode</th>
        <th>collectionCode</th>
        <th>Namespace</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(row, index) in collectionCodes"
        :key="index"
        class="contextMenuCells"
      >
        <td v-html="displayData(row.institutionCode)" />
        <td v-html="displayData(row.collectionCode)" />
        <td class="full_width">
          <CatalogNumberNamespace
            :namespace-id="row.namespace_id"
            @update="updateCatalogNamespace({ index, ...$event })"
          />
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../../../store/actions/actions'
import { GetterNames } from '../../../store/getters/getters'
import CatalogNumberNamespace from './CatalogNumberNamespace.vue'

const store = useStore()
const collectionCodes = computed(() => store.getters[GetterNames.GetCollectionCodeNamespaces])

collectionCodes.value.forEach(item => {
  if (item.namespace_id) {
    store.dispatch(ActionNames.LoadNamespace, item.namespace_id)
  }
})

const updateCatalogNamespace = ({ index, namespaceId }) => {
  store.dispatch(ActionNames.UpdateCatalogNumberNamespace, { index, namespaceId })
}

const displayData = data => data || '<i>(blank/undefined)</i>'
</script>
