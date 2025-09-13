<template>
  <FacetContainer>
    <h3>Asserted Distribution object type</h3>
    <ul class="no_bullets">
      <li
        v-for="type in OBJECT_TYPES"
        :key="type"
      >
        <label>
          <input
            type="checkbox"
            :value="type"
            v-model="params.asserted_distribution_object_type"
          />
          {{ type }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { watch } from 'vue'
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import AssertedDistributionObject from '@/components/ui/SmartSelector/PolymorphicObjectPicker/PolymorphismClasses/AssertedDistributionObject'

const OBJECT_TYPES = AssertedDistributionObject.map((o) => o['singular'])

const params = defineModel({type: Object, required: true})

watch(params, (newVal) => {
  if (!Array.isArray(newVal.asserted_distribution_object_type)) {
    params.value.asserted_distribution_object_type = []
  }
},
{ immediate: true }
)

</script>
