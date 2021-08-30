<template>
  <h2>Recent downloads</h2>
  <table>
    <thead>
      <tr>
        <th
          v-for="header in PROPERTIES"
          :key="header">
          {{ humanize(header) }}
        </th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in list"
        :key="item.id">
        <td
          v-for="property in PROPERTIES"
          :key="property">
          {{ item[property] }}
        </td>
        <td>
          <v-btn
            color="primary"
            medium
            :href="item.url">
            Download
          </v-btn>
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script setup>
import { ref, onBeforeMount } from 'vue'
import { Download } from 'routes/endpoints'
import { humanize } from 'helpers/strings'
import VBtn from 'components/ui/VBtn/index.vue'

const PROPERTIES = ['name', 'description', 'expires', 'times_downloaded']
const list = ref([])

onBeforeMount(async () => {
  list.value = (await Download.all()).body
})

</script>
