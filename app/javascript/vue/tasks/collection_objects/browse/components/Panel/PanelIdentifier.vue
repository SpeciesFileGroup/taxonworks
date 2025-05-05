<template>
  <PanelContainer title="Identifiers">
    <table class="table-attributes">
      <thead>
        <tr class="cell-head">
          <th>Identifier</th>
          <th>On</th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(value, key) in identifiers"
          :key="key"
        >
          <tr>
            <td v-html="key" />
            <td
              class="cell-value"
              v-html="value"
            />
          </tr>
        </template>
      </tbody>
    </table>
  </PanelContainer>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'

const store = useStore()
const identifiers = computed(() => {
  const list = store.getters[GetterNames.GetIdentifiers]
  const newlist = {}

  for (const key in list) {
    list[key].forEach((identifier) => {
      newlist[identifier.objectTag] = key
    })
  }

  return newlist
})
</script>

<style lang="scss">
.table-attributes {
  box-shadow: none;

  tr {
    border-bottom: 1px solid #eaeaea;
  }

  th {
    border-bottom: 2px solid #eaeaea;
  }
  .cell-value {
    font-weight: 500;
    word-break: break-all;
  }

  .cell-head {
    text-transform: uppercase;
  }
}
</style>
