<template>
  <div>
    <VBtn
      color="primary"
      :disabled="!keepGlobalId || !removeGlobalId"
      @click="openModal"
    >
      Preview
    </VBtn>
    <VModal
      v-if="isModalVisible"
      :container-style="{ minWidth: '800px' }"
      @close="() => (isModalVisible = false)"
    >
      <template #header>
        <h3>Preview</h3>
      </template>
      <template #body>
        <table class="table-striped full_width">
          <thead>
            <tr>
              <th class="w-2"></th>
              <th class="w-2">Merged</th>
              <th class="w-2">Unmerged</th>
              <th>Errors</th>
            </tr>
          </thead>
          <tbody>
            <template
              v-for="({ merged, unmerged, errors }, key) in previewResponse"
              :key="key"
            >
              <tr>
                <td>{{ key }}</td>
                <td>{{ merged }}</td>
                <td>{{ unmerged }}</td>
                <td>
                  <div v-if="errors">
                    <ul class="no_bullets">
                      <li v-for="error in errors">{{ error.message }}</li>
                    </ul>
                  </div>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
        <div :key="key">
          <div v-if="false">
            <b>{{ key }}</b>
            <ul>
              <li v-if="merged">Merged: {{ merged }}</li>
              <li v-if="unmerged">Unmerged: {{ unmerged }}</li>
              <li v-if="errors">
                Error
                <ul>
                  <li
                    v-for="item in errors"
                    :key="item.message"
                  >
                    {{ item.message }}
                  </li>
                </ul>
              </li>
            </ul>
          </div>
        </div>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Unify } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  keepGlobalId: {
    type: [String, null],
    required: true
  },
  removeGlobalId: {
    type: [Object, null],
    required: true
  }
})

const isModalVisible = ref(false)
const previewResponse = ref({})

function openModal() {
  isModalVisible.value = true

  Unify.merge({
    remove_global_id: props.removeGlobalId,
    keep_global_id: props.keepGlobalId,
    preview: true
  })
    .then(({ body }) => {
      console.log(body)
      previewResponse.value = body
    })
    .catch(() => {})
}
</script>
