<template>
  <div>
    <VModal
      v-if="isModalVisible"
      @close="isModalVisible = false"
      :container-style="{
        maxWidth: '700px',
        width: '700px'
      }"
    >
      <template #header>
        <h3>Depictions</h3>
      </template>
      <template #body>
        <VSpinner v-if="isLoading" />
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th />
              <th>ID</th>
              <th>Image ID</th>
              <th>Depiction label</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="item in list"
              :key="item.id"
            >
              <td>
                <div class="horizontal-left-content gap-small">
                  <RadialAnnotator :global-id="item.global_id" />
                  <RadialObject :global-id="item.global_id" />
                  <RadialNavigator :global-id="item.global_id" />
                </div>
              </td>
              <td>
                {{ item.id }}
              </td>
              <td>{{ item.image_id }}</td>
              <td v-html="item.object_tag" />
            </tr>
          </tbody>
        </table>
        <VBtn
          class="margin-medium-top"
          color="primary"
          medium
          :disabled="!list.length"
          @click="copyDepictionIds"
        >
          Copy depiction IDs to clipboard
        </VBtn>
      </template>
    </VModal>
    <VBtn
      medium
      color="primary"
      :disabled="!imageId.length"
      @click="isModalVisible = true"
    >
      Depictions
    </VBtn>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import VSpinner from '@/components/spinner.vue'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  imageId: {
    type: Array,
    default: () => []
  }
})

const list = ref([])
const isModalVisible = ref(false)
const isLoading = ref(false)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    isLoading.value = true

    Depiction.filter({
      image_id: props.imageId
    })
      .then(({ body }) => {
        list.value = body
      })
      .finally((_) => {
        isLoading.value = false
      })
  }
})

function copyDepictionIds() {
  navigator.clipboard
    .writeText(JSON.stringify(list.value.map((item) => item.id)))
    .then((_) => {
      TW.workbench.alert.create('Depiction IDs copied to clipboard')
    })
}
</script>
