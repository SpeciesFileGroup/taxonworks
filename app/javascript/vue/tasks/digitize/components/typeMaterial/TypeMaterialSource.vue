<template>
  <form-citation
    v-model="typeMaterial.originCitation"
    :klass="TYPE_MATERIAL"
    original
  />
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations.js'
import { TYPE_MATERIAL } from 'constants/index.js'
import FormCitation from 'components/Form/FormCitation.vue'

const store = useStore()
const typeMaterial = computed({
  get: () => store.getters[GetterNames.GetTypeMaterial],
  set: value => store.commit(MutationNames.SetTypeMaterial, value)
})
</script>
