<template>
  <div class="panel content">
    <h2>Collector global ids</h2>
    <switch-component
      :options="Object.values(TABS)"
      v-model="tabSelected"
    />
    <table>
      <thead>
        <tr>
          <th>Collector</th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="[id, collector] in list"
          :key="id">
          <td>
            <a :href="peopleLink(id)">{{ collector }}</a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script setup>
import { computed, onBeforeMount, ref } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import SwitchComponent from 'components/switch.vue'

const collectors = ref({})
const TABS = {
  With: 'with',
  Without: 'Without'
}
const tabSelected = ref(TABS.With)

const list = computed(() => {
  const property = tabSelected.value === TABS.With
    ? 'with_global_id'
    : 'without_global_id'

  return collectors.value[property] || {}
})

onBeforeMount(async () => {
  collectors.value = (await DwcOcurrence.collectorMetadata()).body
})

const peopleLink = id => `/people/${id}`

</script>
