<template>
  <div>
    <VTooltip
      v-if="store.coordinateOtus.length > 1"
      placement="bottom"
    >
      <VBtn
        color="primary"
        @click="() => (isModalVisible = true)"
      >
        Coordinate OTUs ({{ store.coordinateOtus.length }})
      </VBtn>
      <template #content>
        <ul class="no_bullets">
          <li
            v-for="otu in previewCoordinateOtus"
            :key="otu.id"
            class="horizontal-left-content gap-small"
          >
            <span
              v-if="store.selectedOtus.some((o) => o.id === otu.id)"
              class="font-bold"
            >
              > {{ otu.object_label }}
            </span>
            <span
              v-else
              v-html="otu.object_label"
            />
          </li>
          <li v-if="hiddenCoordinateOtusCount">
            ... and {{ hiddenCoordinateOtusCount }} more
          </li>
        </ul>
      </template>
    </VTooltip>
    <VModal
      v-if="isModalVisible"
      :container-style="{ width: '700px' }"
      @close="closeModal"
    >
      <template #header>
        <h3>Coordinate OTUs</h3>
      </template>
      <template #body>
        <p>
          Select the OTUs to filter the data. Each panel will display
          information according to the selected OTUs.
        </p>
        <input
          v-model="searchText"
          type="text"
          class="full_width margin-medium-bottom"
          placeholder="Filter OTUs..."
        />
        <table class="full_width table-striped">
          <thead>
            <tr>
              <th>
                <div class="horizontal-left-content gap-small">
                  <input
                    type="checkbox"
                    title="Select/deselect all coordinate OTUs"
                    :checked="isEverySelectableOtuSelected"
                    :disabled="!selectableOtus.length"
                    @change="toggleAllOtus"
                  />
                </div>
              </th>
              <th>
                <ButtonUnify
                  :ids="otus.map((o) => o.id)"
                  :model="OTU"
                />
              </th>
              <th>OTU</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="otu in filteredCoordinateOtus"
              :key="otu.id"
            >
              <td class="w-2">
                <input
                  type="checkbox"
                  :value="otu"
                  v-model="otus"
                />
              </td>
              <td class="w-2">
                <div class="horizontal-left-content gap-small">
                  <RadialAnnotator :global-id="otu.global_id" />
                  <RadialObject :global-id="otu.global_id" />
                  <RadialNavigator :global-id="otu.global_id" />
                </div>
              </td>
              <td>
                <span
                  v-if="store.otu?.id === otu.id"
                  v-html="otu.object_tag"
                />
                <a
                  v-else
                  :href="`${RouteNames.BrowseOtu}?otu_id=${otu.id}`"
                  data-turbolinks="false"
                  v-html="otu.object_tag"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </template>
      <template #footer>
        <div class="horizontal-left-content middle gap-small">
          <VBtn
            color="primary"
            @click="applySelection"
          >
            Apply
          </VBtn>
          <span
            v-if="isCurrentOtuUnchecked"
            class="subtle"
          >
            The current OTU is always included in the panels.
          </span>
        </div>
        <ConfirmationModal ref="confirmationModal" />
      </template>
    </VModal>
  </div>
</template>

<script setup>
import { computed, watch, ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import ConfirmationModal from '@/components/ConfirmationModal.vue'
import { useOtuStore } from '../store'
import { OTU } from '@/constants'
import { RouteNames } from '@/routes/routes'

const MAX_TOOLTIP_OTUS = 10

const otus = ref([])
const isModalVisible = ref(false)
const searchText = ref('')
const confirmationModal = ref(null)
const isConfirmingClose = ref(false)
const store = useOtuStore()

const previewCoordinateOtus = computed(() =>
  store.coordinateOtus.slice(0, MAX_TOOLTIP_OTUS)
)

const hiddenCoordinateOtusCount = computed(() =>
  Math.max(store.coordinateOtus.length - MAX_TOOLTIP_OTUS, 0)
)

const filteredCoordinateOtus = computed(() => {
  const term = searchText.value.trim().toLowerCase()

  if (!term) return store.coordinateOtus

  return store.coordinateOtus.filter((otu) =>
    (otu.object_label || '').toLowerCase().includes(term)
  )
})

const selectableOtus = computed(() => filteredCoordinateOtus.value)

const isEverySelectableOtuSelected = computed(
  () =>
    !!selectableOtus.value.length &&
    selectableOtus.value.every((otu) => otus.value.some((o) => o.id === otu.id))
)

function toggleAllOtus(event) {
  const visibleIds = selectableOtus.value.map((otu) => otu.id)
  const keptOtus = otus.value.filter((otu) => !visibleIds.includes(otu.id))

  otus.value = event.target.checked
    ? [...keptOtus, ...selectableOtus.value]
    : keptOtus
}

const isCurrentOtuUnchecked = computed(
  () => !otus.value.some((otu) => otu.id === store.otu?.id)
)

function makeSelectionWithCurrentOtu() {
  const currentOtu = store.coordinateOtus.find(
    (otu) => otu.id === store.otu?.id
  )
  const otherOtus = otus.value.filter((otu) => otu.id !== currentOtu?.id)

  return currentOtu ? [currentOtu, ...otherOtus] : otherOtus
}

const hasUnappliedChanges = computed(() => {
  const appliedIds = store.selectedOtus.map((otu) => otu.id)
  const pendingIds = makeSelectionWithCurrentOtu().map((otu) => otu.id)

  return (
    appliedIds.length !== pendingIds.length ||
    pendingIds.some((id) => !appliedIds.includes(id))
  )
})

function applySelection() {
  store.selectedOtus = makeSelectionWithCurrentOtu()
  isModalVisible.value = false
}

async function closeModal() {
  if (isConfirmingClose.value) return

  if (hasUnappliedChanges.value) {
    isConfirmingClose.value = true

    const ok = await confirmationModal.value.show({
      title: 'Discard changes',
      message:
        'You have changes that have not been applied. Are you sure you want to close without applying them?',
      okButton: 'Close without applying',
      cancelButton: 'Cancel',
      typeButton: 'default'
    })

    isConfirmingClose.value = false

    if (!ok) return
  }

  isModalVisible.value = false
}

watch(isModalVisible, () => {
  otus.value = [...store.selectedOtus]
  searchText.value = ''
})
</script>
