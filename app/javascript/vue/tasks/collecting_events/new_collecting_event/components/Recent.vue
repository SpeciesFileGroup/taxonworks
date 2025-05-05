<template>
  <div>
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <button
      @click="showModalView(true)"
      class="button normal-input button-default button-size separate-left"
      type="button"
    >
      Recent
    </button>
    <VModal
      :container-style="{ width: '90%' }"
      @close="showModalView(false)"
    >
      <template #header>
        <h3>Recent collecting events</h3>
      </template>
      <template #body>
        <table class="full_width">
          <thead>
            <tr>
              <th class="full_width">Object tag</th>
              <th />
            </tr>
          </thead>
          <tbody>
            <tr
              class="contextMenuCells"
              v-for="item in collectingEvents"
              :key="item.id"
              @dblclick="() => selectCollectingEvent(item)"
            >
              <td v-html="item.object_tag" />
              <td>
                <div class="horizontal-left-content gap-small">
                  <VBtn
                    circle
                    color="primary"
                    @click="() => selectCollectingEvent(item)"
                  >
                    <VIcon
                      name="pencil"
                      x-small
                    />
                  </VBtn>
                  <VBtn
                    circle
                    color="destroy"
                    @click="() => removeCollectingEvent(item)"
                  >
                    <VIcon
                      name="trash"
                      x-small
                    />
                  </VBtn>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </template>
    </VModal>
  </div>
</template>

<script setup>
import VSpinner from '@/components/ui/VSpinner'
import VModal from '@/components/ui/Modal'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { CollectingEvent } from '@/routes/endpoints'
import { ref, onBeforeMount } from 'vue'

const emit = defineEmits(['close', 'select'])
const collectingEvents = ref([])
const isLoading = ref(false)

onBeforeMount(() => {
  isLoading.value = true
  CollectingEvent.where({ per: 10, recent: true })
    .then(({ body }) => {
      collectingEvents.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
})

function showModalView(value) {
  emit('close', value)
}

function removeCollectingEvent(index) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    CollectingEvent.destroy(collectingEvents.value[index].id).then(() => {
      collectingEvents.value.splice(index, 1)
    })
  }
}

function selectCollectingEvent(collectingEvent) {
  emit('select', collectingEvent)
  showModalView(false)
}
</script>
