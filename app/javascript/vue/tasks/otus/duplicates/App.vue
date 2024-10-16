<template>
  <div class="task-container">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <h1>Duplicate OTU predictor</h1>

    <NavBar>
      <div class="flex-separate middle gap-medium">
        <ButtonUnify
          :ids="selected"
          :model="OTU"
        />
        <ul class="context-menu">
          <li>
            <VPagination
              :pagination="pagination"
              @next-page="loadDuplicates"
            />
          </li>
          <li>
            <PaginationCount
              v-model="per"
              :pagination="pagination"
              @change="() => loadDuplicates({ page: 1 })"
            />
          </li>
        </ul>
        <VBtn
          color="primary"
          medium
          @click="() => loadDuplicates({ page: 1 })"
          >Refresh</VBtn
        >
      </div>
    </NavBar>
    <table class="full_width">
      <thead>
        <tr>
          <th class="w-2"></th>
          <th>Label</th>
          <th class="w-2">Count</th>
          <th class="w-2" />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
        >
          <td>
            <input
              type="checkbox"
              :value="item.id"
              v-model="selected"
            />
          </td>
          <td v-html="item.label"></td>
          <td>{{ item.count }}</td>
          <td>
            <div class="horizontal-left-content middle gap-small">
              <RadialAnnotator :global-id="item.global_id" />
              <RadialObject :global-id="item.global_id" />
              <RadialNavigator :global-id="item.global_id" />
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { OTU } from '@/constants'
import { Otu } from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import VPagination from '@/components/pagination.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import NavBar from '@/components/layout/NavBar.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import PaginationCount from '@/components/pagination/PaginationCount.vue'

defineOptions({
  name: 'DuplicateOtuPredictor'
})

const per = ref(50)
const list = ref([])
const pagination = ref({})
const selected = ref([])
const isLoading = ref(false)

function loadDuplicates({ page = 1 }) {
  isLoading.value = true
  Otu.duplicates({ page, per: per.value })
    .then((response) => {
      pagination.value = getPagination(response)
      list.value = response.body
    })
    .finally(() => {
      isLoading.value = false
    })
}

onBeforeMount(() => loadDuplicates({ page: 1 }))
</script>

<style scoped>
.task-container {
  width: 1240px;
  margin: 0 auto;
}

table {
  position: relative;
}

th {
  position: sticky;
}
</style>
