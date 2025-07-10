<template>
  <BlockLayout :warning="biologicalAssociationStore.hasUnsaved">
    <template #header>
      <h3>Biological associations</h3>
    </template>
    <template #body>
      <BiologicalAssociationForm
        class="margin-medium-bottom"
        ref="formRef"
        v-model:relationship-lock="
          settings.locked.biological_association.relationship
        "
        v-model:related-lock="settings.locked.biological_association.related"
        @add="addBA"
      />
      <BiologicalAssociationList
        :list="biologicalAssociationStore.biologicalAssociations"
        v-model:lock="settings.locked.biologicalAssociations"
        @delete="biologicalAssociationStore.remove"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { computed, useTemplateRef } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'
import { MutationNames } from '../../store/mutations/mutations'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import BiologicalAssociationForm from '@/components/Form/FormBiologicalAssociation/BiologicalAssociation.vue'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations.js'
import BiologicalAssociationList from '@/components/Form/FormBiologicalAssociation/BiologicalAssociationList.vue'

const store = useStore()
const biologicalAssociationStore = useBiologicalAssociationStore()
const form = useTemplateRef('formRef')

const settings = computed({
  get: () => store.getters[GetterNames.GetSettings],
  set: (value) => store.commit(MutationNames.SetSettings, value)
})

function addBA(ba) {
  biologicalAssociationStore.add(ba)
  form.value.resetForm()
}
</script>
