<template>
  <VModal
    v-if="isModalVisible"
    :container-style="{ maxWidth: '800px', width: 'auto' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Related biological associations</h3>
    </template>

    <template #body>
      <VSpinner v-if="isLoading" />
      <ul>
        <li
          v-for="item in biologicalAssociations"
          :key="item.id"
          v-html="item.object_tag"
        />
      </ul>
    </template>
  </VModal>
  <VBtn
    color="primary"
    @click="isModalVisible = true"
  >
    Related ({{ total }})
  </VBtn>
</template>

<script setup>
import { BiologicalAssociation } from 'routes/endpoints'
import { ref, onBeforeMount, watch } from 'vue'
import { OTU, COLLECTION_OBJECT } from 'constants/index.js'
import VModal from 'components/ui/Modal.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import getPagination from 'helpers/getPagination'
import VSpinner from 'components/spinner.vue'

const param = {
  [OTU]: 'otu_id',
  [COLLECTION_OBJECT]: 'collection_object_id'
}

const props = defineProps({
  current: {
    type: Object,
    required: true
  },

  itemId: {
    type: Number,
    required: true
  },

  itemType: {
    type: String,
    required: true
  }
})

const isModalVisible = ref(false)
const biologicalAssociations = ref([])
const total = ref('?')
const isLoading = ref(false)

onBeforeMount(async () => {
  const payload = {
    [param[props.itemType]]: [props.itemId],
    per: 1
  }
  const response = await BiologicalAssociation.where(payload)

  total.value = getPagination(response).total - 1
})

watch(isModalVisible, async (newVal) => {
  if (newVal && !biologicalAssociations.value.length) {
    isLoading.value = true
    const { body } = await BiologicalAssociation.all({
      [param[props.itemType]]: [props.itemId]
    })

    isLoading.value = false

    biologicalAssociations.value = body.filter(
      (item) => item.id !== props.current.id
    )
  }
})
</script>
