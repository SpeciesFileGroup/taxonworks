<template>

  <div class="connector" />

  <div class="lead-items">
    <div class="flex-separate full_width">
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
          Add an otu
        </VBtn>
      </div>

      <a
        :href="printKeyLink"
        target="_blank"
      >
        print key
      </a>
    </div>

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

  <LeadItemOtuModal
    v-model="modalVisible"
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

const printKeyLink = computed(() => {
  return `${RouteNames.PrintKey}?lead_id=${store.root.id}&lead_items=true`
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
      store.loadKey(store.lead.id)
    })
    .catch(() => {})
    .finally(() => { store.setLoading(false) })
}

function leadItemOtuDeleted(otuId) {
  if (!window.confirm('Are you sure you want to delete this otu row?')) {
    return
  }

  store.setLoading(true)
  LeadItem.destroyItemInChildren({
    otu_id: otuId,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Removed otu from lists.', 'notice')
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

</script>

<style scoped>
.connector {
  width: 12px;
  height: 2em;
  background: #fff;
  z-index: -100;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 0px 15px 0px;
  margin: 0px auto;
  flex-shrink: 0;
}

.lead-items {
  padding: 1em 2em;
  box-shadow: rgba(36, 37, 38, 0.08) 4px 4px 15px 0px;
  border-radius: 0.9rem;
  background-color: #fff;
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

.lead_otu_row:nth-child(odd) {
  background-color: rgb(240, 240, 240);
}

.radials {
  float: right;
}

.spacer {
  height: calc(26px + 1em);
}

.lead_item_button {
  width: 10em;
  margin-bottom: 1em;
  margin-right: 0.5em;
}

</style>