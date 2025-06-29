<template>
  <FacetContainer>
    <h3>Licenses</h3>
    <ul class="no_bullets">
      <li
        v-for="lic in licenses"
        :key="lic.key"
      >
        <label>
          <input
            name="license"
            :value="lic.key"
            v-model="params[paramLicenses]"
            type="checkbox"
          />
          <span>{{ lic.label }}</span>
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { ref, onBeforeMount, watch } from 'vue'
import { Attribution } from '@/routes/endpoints'
import { URLParamsToJSON } from '@/helpers/url/parse.js'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'

const props = defineProps({
  paramLicenses: {
    type: String,
    required: true
  },
})

const params = defineModel({
  type: Object,
  default: () => ({})
})

const licenses = ref([])

watch(
  () => params.value[props.paramLicenses],
  () => {
    params.value[props.paramLicenses] ||= []
  },
  { immediate: true }
)

onBeforeMount(() => {
  Attribution.licenses().then(({ body }) => {
    licenses.value = Object.entries(body).map(([key, { name, link }]) => ({
      key,
      label: `${name}: ${link}`
    }))

    const urlParams = URLParamsToJSON(location.href)
    params.value[props.paramLicenses] = urlParams[props.paramLicenses] || []
  })
})
</script>

<style scoped>
li {
  margin-bottom: 4px;
}
</style>
