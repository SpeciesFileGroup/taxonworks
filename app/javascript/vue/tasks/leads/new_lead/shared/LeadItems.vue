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
        <div
          v-if="otuIndices.findIndex((c) => (c == i)) != -1"
          class="inline"
        >
          <div class="in" />
          <div
            title="Remove OTU from this lead"
            :class="['remove', 'circle-button', 'btn-delete',
              { 'btn-disabled': leadItemCount(i) == 1 }]"
            @click="() => removeOtuIndex(i)"
          />
        </div>
        <div
          v-else
          class="inline"
        >
          <span
            class="out margin-xsmall-left"
            title="Add OTU to this lead and remove from others"
            @click="() => addOtuIndex(i)"
          >
            +
          </span>
          <span
            class="out"
            title="Add OTU to this lead and don't remove from others"
            @click="() => addAdditionalOtuIndex(i)"
          >
            ++
          </span>
        </div>
        <div
          v-html="otu.object_tag"
          class="flex-grow-2"
          :class="{ highlight: otuIndices.findIndex((c) => (c == i)) != -1 }"
        />

        <div class="flex-row">
          <radial-object :global-id="otu.global_id" />
          <span
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

.in {
  width: 30px;
  height: 24px;
}

.out {
  display: inline-block;
  width: 24px;
  height: 24px;
  line-height: 24px;
  margin-right: 6.5px;
  cursor: pointer;
  vertical-align: bottom;
  text-align: center;
  background-color: var(--color-create);
  color: white;
}

.remove {
  vertical-align: middle;
  margin-left: 3.25px;
  margin-right: 3.25px;
}

.lead_otu_rows {
  border: solid 1px var(--border-color);
  padding-left: 1px;
  padding-right: 1px;
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

.highlight {
  background-color: var(--feedback-info-text-color);
  border: 1px solid var(--feedback-info-border-color);
}

</style>