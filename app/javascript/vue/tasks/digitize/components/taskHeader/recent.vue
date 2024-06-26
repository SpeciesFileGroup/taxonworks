<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="isModalVisible = true"
    >
      Recent
    </button>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '90vw' }"
      @close="isModalVisible = false"
    >
      <template #header>
        <h3>Recent collection objects</h3>
      </template>
      <template #body>
        <VSpinner v-if="isLoading" />
        <table class="full_width">
          <thead>
            <tr>
              <th>Total</th>
              <th>Family</th>
              <th>Genus</th>
              <th>Scientific name</th>
              <th>Identifier</th>
              <th>Biocuration attributes</th>
              <th>Level 1</th>
              <th>Level 2</th>
              <th>Level 3</th>
              <th>Verbatim locality</th>
              <th>Date start</th>
              <th>Container</th>
              <th>Update at</th>
              <th />
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(item, index) in list"
              :key="item.id"
              class="contextMenuCells"
              :class="{ even: index % 2 == 0 }"
              @dblclick="() => sendCO(item)"
            >
              <td>{{ item.dwc_attributes.individualCount }}</td>
              <td>{{ item.dwc_attributes.family }}</td>
              <td>{{ item.dwc_attributes.genus }}</td>
              <td>{{ item.dwc_attributes.scientificName }}</td>
              <td
                v-if="item.identifier_from_container"
                v-html="item.object_tag"
              />
              <td v-else>
                {{ item.dwc_attributes.catalogNumber }}
              </td>
              <td>{{ item.biocuration }}</td>
              <td>{{ item.dwc_attributes.country }}</td>
              <td>{{ item.dwc_attributes.stateProvince }}</td>
              <td>{{ item.dwc_attributes.county }}</td>
              <td>{{ item.dwc_attributes.verbatimLocality }}</td>
              <td>{{ item.dwc_attributes.eventDate }}</td>
              <td v-html="item.container" />
              <td>{{ item.updated_at }}</td>
              <td>
                <VBtn
                  circle
                  color="primary"
                  @click="() => sendCO(item)"
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
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VModal from '@/components/ui/Modal'
import VSpinner from '@/components/ui/VSpinner'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { CollectionObject } from '@/routes/endpoints'
import { ref, watch } from 'vue'

const emit = defineEmits(['selected'])
const isModalVisible = ref(false)
const list = ref([])
const isLoading = ref(false)

watch(isModalVisible, (newVal) => {
  if (newVal) {
    isLoading.value = true
    CollectionObject.reportDwc({ per: 10 }).then(({ body }) => {
      list.value = body
      isLoading.value = false
    })
  }
})

function sendCO(item) {
  isModalVisible.value = false
  emit('selected', item)
}
</script>
