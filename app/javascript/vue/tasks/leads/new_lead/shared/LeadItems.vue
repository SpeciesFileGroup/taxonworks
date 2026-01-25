<template>

  <div class="connector" />

  <div class="panel lead-items">
    <div class="flex-separate full_width">
      <div class="button_row">
        <div>
          <VBtn
            v-if="showAddOtu"
            medium
            color="create"
            @click="addOtu"
            class="lead_item_button"
          >
            Add OTUs
          </VBtn>

          <VBtn
            v-if="showResetOtus"
            medium
            color="create"
            @click="resetLeadItems"
            class="lead_item_button"
            title="Reset all OTUs to the right lead"
          >
            Reset all OTUs
          </VBtn>

          <VBtn
            v-if="showSendToInteractiveKey"
            medium
            color="primary"
            @click="() => { matricesModalVisible = true }"
            class="lead_item_long_button"
          >
            Send OTUs to interactive key
          </VBtn>
        </div>

        <div class="button-row-text">
          Changes below are auto-updated
        </div>
      </div>
    </div>

    <div class="lead_otu_rows">
      <div
        v-for="(otu, i) in store.lead_item_otus.parent"
        :index="otu.id"
        class="lead_otu_row flex-row"
      >
        <Transition name="otu-status" mode="out-in">
          <div
            v-if="otuIndices.findIndex((c) => (c == i)) != -1"
            class="status-glow"
            :key="'in-' + i"
            :title="leadItemCount(i) > 1 ? 'Remove OTU from this lead' : null"
            :class="{ 'cursor-pointer': leadItemCount(i) > 1 }"
            @click="() => (leadItemCount(i) > 1 ? removeOtuIndex(i) : null)"
          >
            <span
              v-if="leadItemCount(i) > 1"
              class="remove-otu-button"
              title="Remove OTU from this lead"
            >×</span>
          </div>

          <span
            v-else
            class="add-otu-button"
            :key="'out-' + i"
            :title="addOtuTooltip"
            @click.prevent="() => handleAddClick(i)"
            @dblclick.prevent="() => handleAddDblClick(i)"
          ><span class="add-otu-button-inner">+</span></span>
        </Transition>

        <div
          class="flex-grow-2"
          :class="{ excluded: otuIndices.findIndex((c) => (c == i)) == -1 }"
        >
          <a
            :href="`${RouteNames.BrowseOtu}?otu_id=${otu.id}`"
            v-html="otu.object_tag"
            target="_blank"
          />
        </div>

        <div class="flex-row gap-xsmall">
          <RadialObject :global-id="otu.global_id" />
          <div
            class="circle-button btn-delete"
            title="Remove OTU from all leads"
            @click="() => leadItemOtuDeleted(otu.id)"
          />
        </div>
      </div>
    </div>
  </div>

  <LeadItemOtuModal
    v-model="otusModalVisible"
    :child-index="position"
  />

  <InteractiveKeyPickerModal
    v-if="matricesModalVisible"
    v-model:visible="matricesModalVisible"
    v-model:chosen-matrix-id="chosenMatrixId"
    @click="sendToInteractiveKey"
  />

</template>

<script setup>
import LeadItemOtuModal from './LeadItemOtuModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import useStore from '../store/leadStore.js'
import { Lead, LeadItem } from '@/routes/endpoints'
import { computed, ref } from 'vue'
import { useDoubleClick } from '@/composables'
import { RouteNames } from '@/routes/routes'
import InteractiveKeyPickerModal from './InteractiveKeyPickerModal.vue'

const props = defineProps({
  leadId: {
    type: Number,
    required: true
  },
  showAddOtu: {
    type: Boolean,
    default: false
  },
  showResetOtus: {
    type: Boolean,
    default: false
  },
  position: {
    type: Number,
    required: true
  }
})

const store = useStore()

const otusModalVisible = ref(false)
const matricesModalVisible = ref(false)
const chosenMatrixId = ref(null)

const otuIndices = computed(() => {
  // A list of indices into the parent otu list indicating which of the parent
  // otus are checked for this child.
  return store.lead_item_otus.children[props.position].otu_indices
})

const addOtuTooltip = 'Click: add to this lead, remove from others — Double-click: keep on others'

const { handleClick: handleAddClick, handleDoubleClick: handleAddDblClick } = useDoubleClick(
  (otuIndex) => addOtuIndex(otuIndex),
  (otuIndex) => addAdditionalOtuIndex(otuIndex),
  300
)

const showSendToInteractiveKey = computed(() => {
  if (
    store.children.length == 2 && props.position == 1 &&
    // All lead items are on this lead:
    store.lead_item_otus.children[0].otu_indices.length == 0
  ) {
    return true
  } else {
    return false
  }
})

function addOtu() {
  otusModalVisible.value = true
}

function resetLeadItems() {
  if (!window.confirm('Are you sure you want to move all OTUs to the right-most lead?')) {
    return
  }

  store.setLoading(true)
  Lead
    .resetLeadItems(store.lead.id)
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Reset all lead items to the right lead.')
    })
    .catch(() => {})
    .finally(() => { store.setLoading(false) })
}

function addOtuIndex(otuIndex) {
  store.addOtuIndex(props.position, otuIndex)
}

function addAdditionalOtuIndex(otuIndex) {
  store.addOtuIndex(props.position, otuIndex, false)
}

function removeOtuIndex(otuIndex) {
  if (leadItemCount(otuIndex) == 1) {
    return
  }

  store.removeOtuIndex(props.position, otuIndex)
}

function leadItemOtuDeleted(otuId) {
  if (!window.confirm('Are you sure you want to delete this OTU row?')) {
    return
  }

  store.setLoading(true)
  LeadItem.destroyItemInChildren({
    otu_id: otuId,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Removed OTU from lists.', 'notice')
    })
    .catch(() => {})
    .finally(() => { store.setLoading(false) })
}

function leadItemCount(i) {
  let selectedCount = 0

  store.lead_item_otus.children.forEach((leadChildOtus) => {
    if (leadChildOtus.otu_indices.includes(i)) {
      selectedCount += 1
    }
  })

  return selectedCount
}

function sendToInteractiveKey() {
  const otuIds = store.lead_item_otus.children[1].otu_indices.map(
    (i) => store.lead_item_otus.parent[i].id
  ).join('|')

  sessionStorage.setItem('key_to_interactive_key_otu_ids', otuIds)

  window.location.href = `${RouteNames.InteractiveKeys}?observation_matrix_id=${chosenMatrixId.value}&lead_id=${store.lead.id}`
}

</script>

<style scoped>
.connector {
  width: 12px;
  height: 2em;
  background: var(--panel-bg-color);
  z-index: -100;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 0px 15px 0px;
  margin: 0px auto;
  flex-shrink: 0;
}

.lead-items {
  padding: 1em 2em;
}

.status-glow {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background-color: var(--color-status-included);
  box-shadow: 0 0 8px var(--color-status-included-glow);
  margin-left: 6px;
  margin-right: 8px;
  flex-shrink: 0;
}

.add-otu-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  position: relative;
  width: 24px;
  height: 24px;
  margin-left: 6px;
  margin-right: 8px;
  border-radius: 50%;
  color: white;
  font-size: 13px;
  font-weight: bold;
  line-height: 1;
  cursor: pointer;
  user-select: none;
  flex-shrink: 0;
}

.add-otu-button-inner {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background-color: var(--color-create);
  font-size: 12px;
  line-height: 1;
  pointer-events: none;
}

.remove-otu-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 14px;
  height: 14px;
  border-radius: 50%;
  background-color: var(--color-delete);
  color: white;
  font-size: 11px;
  font-weight: bold;
  line-height: 1;
  cursor: pointer;
}

.lead_otu_rows {
  border: solid 1px var(--border-color);
  padding-left: 1px;
  padding-right: 1px;
}

.lead_otu_row {
  align-items: center;
}

.lead_otu_row:nth-child(odd) {
  background-color: var(--table-row-bg-odd);
}

.spacer {
  height: calc(26px + 1em);
}

.lead_item_button {
  width: 10em;
  margin-right: 0.5em;
}

.button_row {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5em;
  margin-bottom: 1em;
}

.button_row_text {
  flex-grow: 2;
}

.excluded {
  opacity: 0.6;
}

.otu-status-enter-active,
.otu-status-leave-active {
  transition: opacity 0.15s ease, transform 0.15s ease;
}

.otu-status-enter-from,
.otu-status-leave-to {
  opacity: 0;
  transform: scale(0.8);
}

</style>
