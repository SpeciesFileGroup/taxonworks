<template>
  <VBtn
    medium
    color="primary"
    @click="isModalVisible = true"
  >
    Recent
  </VBtn>
  <VModal
    v-if="isModalVisible"
    :container-style="{ width: '80vw' }"
    @close="isModalVisible = false"
  >
    <template #header>
      <h3>Recent simple keys</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <table
        v-else-if="list.length"
        class="full_width"
      >
        <thead>
          <tr>
            <th>Title</th>
            <th>Root OTU</th>
            <th>Taxa</th>
            <th>Updated</th>
            <th>By</th>
            <th />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in list"
            :key="item.id"
            class="contextMenuCells"
            :class="{ even: index % 2 == 0 }"
            @dblclick="() => sendItem(item)"
          >
            <td>{{ item.text }}</td>
            <td v-html="item.otu?.object_tag ?? '—'" />
            <td>{{ item.otus_count }}</td>
            <td>{{ item.key_updated_at_in_words }} ago</td>
            <td>{{ item.key_updated_by }}</td>
            <td>
              <VBtn
                circle
                color="primary"
                @click="() => sendItem(item)"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
            </td>
          </tr>
        </tbody>
      </table>
      <div
        v-else
        class="small_type padding-medium text-center"
      >
        No recently updated simple keys yet.
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { Lead } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const emit = defineEmits(['selected'])

const isModalVisible = ref(false)
const list = ref([])
const isLoading = ref(false)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    isLoading.value = true
    Lead.all({
      is_virtual: true,
      recent: true,
      load_root_otus: true,
      per: 10
    })
      .then(({ body }) => {
        list.value = body
      })
      .catch(() => {
        list.value = []
      })
      .finally(() => {
        isLoading.value = false
      })
  }
})

function sendItem(item) {
  isModalVisible.value = false
  emit('selected', item)
}
</script>
