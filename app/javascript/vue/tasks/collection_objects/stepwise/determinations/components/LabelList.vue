<template>
  <div>
    <table>
      <thead>
        <tr>
        <th/>
        <th>Label</th>
        <th>Count</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in list">
          <td>
            <v-btn
              color="primary"
              medium
            >
              Set
            </v-btn>
          </td>
          <td>{{ item.buffered_determinations }}</td>
          <td>{{ item.count_buffered }}</td>
        </tr>
      </tbody>
    </table>

  </div>
</template>

<script setup>
import { ref } from 'vue'
import { CollectionObject } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import getPagination from 'helpers/getPagination'

const list = ref([])
const pagination = ref({})

const loadPage = (page = 1) => {
  const params = {
    count_cutoff: 100,
    per: 10,
    page
  }

  CollectionObject.stepwiseDeterminations(params).then((request) => {
    list.value = body
    pagination.value = getPagination(request)
  })
}

loadPage(1)

</script>