<template>
  <FacetContainer>
    <h3>Identifier type</h3>
    <select
      v-model="params.type"
      class="full_width"
    >
      <option :value="undefined">Any</option>
      <optgroup
        v-for="(group, groupKey) in typeList"
        :key="groupKey"
        :label="humanize(groupKey)"
      >
        <option
          v-for="(item, typeName) in group.all"
          :key="typeName"
          :value="typeName"
        >
          {{ item.label }}
        </option>
      </optgroup>
    </select>
  </FacetContainer>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { Identifier } from '@/routes/endpoints'
import { humanize } from '@/helpers'

const params = defineModel({
  type: Object,
  required: true
})

const typeList = ref({})

onBeforeMount(() => {
  Identifier.types().then(({ body }) => {
    typeList.value = body
  })
})
</script>
