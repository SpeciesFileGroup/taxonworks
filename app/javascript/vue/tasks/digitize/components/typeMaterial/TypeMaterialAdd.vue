<template>
  <VBtn
    color="create"
    medium
    :disabled="!isDataCompleted"
    @click="store.dispatch(ActionNames.AddTypeSpecimen)"
  >
    {{
      typeMaterial.id
        ? 'Update'
        : 'Add'
    }}
  </VBtn>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import VBtn from 'components/ui/VBtn/index.vue'

const store = useStore()
const typeMaterial = computed(() => store.getters[GetterNames.GetTypeMaterial])
const isDataCompleted = computed(() => typeMaterial.value.protonymId && typeMaterial.value.type)
</script>
