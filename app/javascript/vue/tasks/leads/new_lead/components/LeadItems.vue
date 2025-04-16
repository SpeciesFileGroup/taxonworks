<template>

  <div>
    <div
      class="lead_item_buttons"
      v-if="otuList.length > 0"
    >
      <VBtn
        :disabled="checked.length != 1"
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

    <div
      v-if="otuList && checked"
      v-for="(otu, i) in otuList"
      :index="otu.id"
      class="lead_otu_row"
    >
      <span
        v-if="checked.findIndex((c) => (c == i)) != -1"
        class="in"
      >
        &#10003;
      </span>

      <span
        v-else
        class="out"
        @click="emit('addOtuIndex', i)"
      />
      <span v-html="otu.object_tag" />

      <span class="horizontal-right-content gap-small radials">
        <radial-object :global-id="otu.global_id" />
        <span
          class="circle-button btn-delete"
          @click="emit('leadItemDeleted', otu.id)"
          >Remove
        </span>
      </span>
    </div>

    <VModal
      v-if="modalVisible"
      @close="() => { modalVisible = false }"
      :container-style="{
        width: '80vw'
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
            emit('otuSelected', otu.id)
          }"
        />
      </template>
    </VModal>
  </div>

</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import RadialObject from '@/components/radials/navigation/radial.vue'
import SmartSelector from '@/components/ui/SmartSelector.vue'
import { Lead } from '@/routes/endpoints'
import { OTU } from '@/constants'
import { ref } from 'vue'
import { useStore } from '../store/useStore.js'

const props = defineProps({
  otuList: {
    type: Array,
    default: []
  },
  checked: {
    type: Array,
    default: []
  },
  leadId: {
    type: Number,
    required: true
  },
  showAddOtu: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['addOtuIndex', 'leadItemDeleted', 'otuSelected'])

const store = useStore()

const modalVisible = ref(false)

function addOtu() {
  modalVisible.value = true
}

function setLeadOtu() {
  const checkedOtu = props.otuList[props.checked[0]]
  // TODO? check if this is a new/different otu
  const payload = {
    lead: {
      otu_id: checkedOtu.id
    }
  }
  Lead.update(props.leadId, payload)
    .then(() => {
      store.loadKey(store.lead.id)
    })
    .catch(() => {})
}

</script>

<style scoped>
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

.lead_item_buttons {
  display: inline-block;
}

.lead_item_button {
  width: 10em;
  margin-bottom: 1em;
  margin-right: 0.5em;
}
</style>