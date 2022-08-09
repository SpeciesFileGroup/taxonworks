<template>
  <div class="separate-bottom">
    <p>Type</p>
    <ul class="no_bullets">
      <template
        v-for="(_, key) in nomenclatureCodeTypes"
        :key="key"
      >
        <li>
          <label>
            <input
              class="capitalize"
              type="radio"
              v-model="typeMaterial.type"
              :value="key"
            >
            {{ key }}
          </label>
        </li>
      </template>
    </ul>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { TypeMaterial } from 'routes/endpoints'
import { MutationNames } from '../../store/mutations/mutations.js'
import { GetterNames } from '../../store/getters/getters.js'

const store = useStore()
const typeList = ref({})

const typeMaterial = computed({
  get: () => store.getters[GetterNames.GetTypeMaterial],
  set: value => store.commit(MutationNames.SetTypeMaterial, value)
})

const nomenclatureCodeTypes = computed(() => {
  const nomenclatureCode = store.getters[GetterNames.GetTypeMaterial].taxon?.nomenclatural_code

  return typeList.value[nomenclatureCode]
})

TypeMaterial.types().then(({ body }) => {
  typeList.value = body
})

</script>
