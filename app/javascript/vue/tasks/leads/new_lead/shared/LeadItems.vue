<template>

  <div class="connector" />

  <div class="panel lead-items">
    <div class="flex-separate full_width">
      <div class="button_row">
        <div>
        <VBtn
          :disabled="otuIndices.length != 1"
          medium
          color="create"
          @click="setLeadOtu"
          class="lead_item_button"
        >
          Set as lead OTU
        </VBtn>

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
          @click="sendToInteractiveKey"
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
        class="lead_otu_row"
      >
        <span v-if="otuIndices.findIndex((c) => (c == i)) != -1">
          <span class="in">
            &#10003;
          </span>
          <span
            title="Remove OTU from this lead"
            :class="['remove', 'circle-button', 'btn-delete',
              { 'btn-disabled': leadItemCount(i) == 1 }]"
            @click="() => removeOtuIndex(i)"
          />
        </span>
        <span v-else>
          <span
            class="out circle btn-radio-like-add"
            title="Add OTU to this lead and remove from others"
            @click="() => addOtuIndex(i)"
          />
          <span
            class="out btn-checkbox-like-add"
            title="Add OTU to this lead and don't remove from others"
            @click="() => addAdditionalOtuIndex(i)"
          />
        </span>
        <span v-html="otu.object_tag" />

        <span class="horizontal-right-content gap-small radials">
          <radial-object :global-id="otu.global_id" />
          <span
            class="circle-button btn-delete"
            title="Remove OTU from all leads"
            @click="() => leadItemOtuDeleted(otu.id)"
          />
        </span>
      </div>
    </div>
  </div>

  <LeadItemOtuModal
    v-model="modalVisible"
    :child-index="position"
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

const modalVisible = ref(false)

const otuIndices = computed(() => {
  // A list of indices into the parent otu list indicating which of the parent
  // otus are checked for this child.
  return store.lead_item_otus.children[props.position].otu_indices
})

const showSendToInteractiveKey = computed(() => {
  if (
    !!store.root.observation_matrix_id &&
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
  modalVisible.value = true
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

function setLeadOtu() {
  const checkedOtu =
    store.lead_item_otus.parent[
      store.lead_item_otus.children[props.position].otu_indices[0]
    ]
  const payload = {
    lead: {
      otu_id: checkedOtu.id
    }
  }

  store.setLoading(true)
  Lead.update(props.leadId, payload)
    .then(() => {
      TW.workbench.alert.create('Set and saved OTU on lead.', 'notice')
      store.loadKey(store.lead.id)
    })
    .catch(() => {})
    .finally(() => { store.setLoading(false) })
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

  window.location.href = `${RouteNames.InteractiveKeys}?observation_matrix_id=${store.root.observation_matrix_id}&otu_filter=${otuIds}&lead_id=${store.lead.id}`
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
  display: inline-block;
  width: 24px;
  height: 24px;
  margin-right: 6.5px;
  color: green;
  vertical-align: middle;
  text-align: center;
}

.out {
  display: inline-block;
  width: 24px;
  height: 24px;
  margin-right: 6.5px;
  cursor: pointer;
  vertical-align: middle;
  text-align: center;
  background-color: var(--color-create);
  color: white;
}

.circle {
  border-radius: 50%;
}

.remove {
  display: inline-block;
  vertical-align: middle;
  margin-right: 6.5px;
}

.lead_otu_rows {
  border: solid 1px var(--border-color);
  padding-left: 1px;
  padding-right: 1px;
}

.lead_otu_row:nth-child(odd) {
  background-color: var(--table-row-bg-odd);
}

.radials {
  float: right;
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


</style>