<template>
  <BlockLayout>
    <template #header>
      <h3>Biological associations</h3>
    </template>
    <template #body>
      <BiologicalAssociationForm
        class="margin-medium-bottom"
        ref="formRef"
        v-model:relationship-lock="
          settings.locked.biologicalAssociation.relationship
        "
        v-model:related-lock="settings.locked.biologicalAssociation.related"
        @add="addBA"
      />
      <BiologicalAssociationList
        :list="store.biologicalAssociations"
        v-model:lock="settings.locked.biologicalAssociation.list"
        @delete="store.remove"
      />
    </template>
  </BlockLayout>
</template>

<script setup>
import { useTemplateRef } from 'vue'
import useSettingStore from '../store/settings.js'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import BiologicalAssociationForm from './BiologicalAssociation/BiologicalAssociation.vue'
import useBiologicalAssociationStore from '../store/biologicalAssociations'
import BiologicalAssociationList from './BiologicalAssociation/BiologicalAssociationList.vue'

const settings = useSettingStore()
const store = useBiologicalAssociationStore()
const form = useTemplateRef('formRef')

function addBA(ba) {
  store.add(ba)
  form.value.resetForm()
}
</script>
