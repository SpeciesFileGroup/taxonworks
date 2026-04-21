<template>
  <VBtn
    color="primary"
    medium
    @click="isVisible = true"
  >
    Recent
  </VBtn>

  <VModal
    v-if="isVisible"
    :container-style="{ width: '560px' }"
    @close="isVisible = false"
  >
    <template #header>
      <h3>Recent buildings</h3>
    </template>
    <template #body>
      <VSpinner v-if="isLoading" />
      <table
        v-else
        class="full_width table-striped"
      >
        <thead>
          <tr>
            <th>Name</th>
            <th class="w-2" />
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="item in buildings"
            :key="item.id"
          >
            <td v-html="item.object_tag" />
            <td>
              <VBtn
                color="primary"
                circle
                @click="select(item)"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>
            </td>
          </tr>
          <tr v-if="!buildings.length">
            <td
              colspan="2"
              class="muted"
            >
              No recent buildings found.
            </td>
          </tr>
        </tbody>
      </table>
    </template>
  </VModal>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Container } from '@/routes/endpoints'
import VModal from '@/components/ui/Modal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const emit = defineEmits(['select'])

const isVisible = ref(false)
const isLoading = ref(false)
const buildings = ref([])

watch(isVisible, (val) => {
  if (val) {
    isLoading.value = true
    Container.where({ type: 'Container::Building', per: 10, recent: true })
      .then(({ body }) => { buildings.value = body })
      .finally(() => { isLoading.value = false })
  }
})

function select(item) {
  emit('select', item)
  isVisible.value = false
}
</script>
