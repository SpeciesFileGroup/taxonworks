<template>
  <BlockLayout>
    <template #header>
      <h3>Licenses</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="lic in licenses"
          :key="lic.key"
        >
          <label>
            <input
              name="license"
              :value="lic.key"
              v-model="license"
              type="radio"
            />
            <span v-if="lic.key != null">{{ lic.key }}: </span>{{ lic.label }}
          </label>
        </li>
      </ul>
    </template>
  </BlockLayout>
</template>

<script setup>
import { ref, computed, onBeforeMount } from 'vue'
import { useStore } from 'vuex'
import { Attribution } from '@/routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const store = useStore()

const licenses = ref([])

const license = computed({
  get: () => store.getters[GetterNames.GetLicense],
  set(value) {
    store.commit(MutationNames.SetLicense, value)
  }
})

onBeforeMount(() => {
  Attribution.licenses().then(({ body }) => {
    licenses.value = Object.keys(body).map((key) => ({
      key,
      label: body[key]
    }))

    licenses.value.push({
      label: '-- None --',
      key: null
    })
  })
})
</script>

<style scoped>
li {
  margin-bottom: 4px;
}
</style>
