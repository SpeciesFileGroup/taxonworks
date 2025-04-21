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
          Set as lead otu
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
      <span
        v-if="otuIndices.findIndex((c) => (c == i)) != -1"
        class="in"
      >
        &#10003;
      </span>

      <span
        v-else
        class="out"
        @click="() => addOtuIndex(i)"
      />
      <span v-html="otu.object_tag" />

      <span class="horizontal-right-content gap-small radials">
        <radial-object :global-id="otu.global_id" />
        <span
          class="circle-button btn-delete"
          @click="() => { leadItemDeleted(otu.id) }"
          >Remove
        </span>
      </span>
    </div>
  </div>

  <VModal
    v-if="modalVisible"
    @close="() => { modalVisible = false }"
    :container-style="{
      width: '600px'
    }"
  >
    <template #header>
      <h3>Select an OTU to add to the lists</h3>
    </template>
    <template #body>
      <SmartSelector
        model="otus"
        klass="otus"
        :target="OTU"
        :pin-type="OTU"
        @selected="(otu) => {
          modalVisible = false
          otuSelected(otu.id)
        }"
      />
    </template>
  </VModal>

</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import { Lead, LeadItem } from '@/routes/endpoints'
import { OTU } from '@/constants'
import { computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/useStore.js'

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

function addOtuIndex(otu_index) {
  store.addOtuIndex(props.position, otu_index)
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

function leadItemDeleted(otuId) {
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

function otuSelected(otuId) {
  store.setLoading(true)
  LeadItem.addLeadItemToChildLead({
    otu_id: otuId,
    parent_id: store.lead.id
  })
    .then(() => {
      store.loadKey(store.lead.id)
      TW.workbench.alert.create('Added otu to the last lead list.', 'notice')
    })
    .catch(() => {})
    .finally(() => { store.setLoading(false) })
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
  width: 16px;
  height: 16px;
  margin-right: .5em;
  color: green;
  text-align: center;
}

.out {
  display: inline-block;
  width: 10px;
  height: 10px;
  margin-right: .5em;
  cursor: pointer;
  border: 2px solid rgb(70, 70, 70);
  vertical-align: middle;
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