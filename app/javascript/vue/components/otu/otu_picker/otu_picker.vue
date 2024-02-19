<template>
  <div class="vue-otu-picker gap-small">
    <VAutocomplete
      :input-id="inputId"
      url="/otus/autocomplete"
      label="label_html"
      min="2"
      display="label"
      :clear-after="clearAfter"
      :input-attributes="inputAttributes"
      placeholder="Select an OTU"
      param="term"
      @found="($event) => (foundSomething = $event)"
      @get-item="emitOtu"
      @get-input="callbackInput"
    />
    <div class="flex-wrap-column create-otu-panel">
      <MatchTaxonName
        v-if="!foundSomething"
        class="panel content match-otu-box"
        :otu-name="otuName"
        @selected="
          (data) => {
            createOtu({
              taxonId: data.taxon.id,
              name: data.otuName
            })
          }
        "
        @create-new="() => (create = true)"
      />
      <div
        v-if="create"
        class="new-otu-panel panel content"
      >
        <span
          class="close-panel small-icon"
          data-icon="close"
          @click="() => (create = false)"
        />
        <div class="field label-above">
          <label>Name</label>
          <input
            type="text"
            class="full_width"
            v-model="otuName"
          />
        </div>
        <div class="field label-above">
          <label>Taxon name</label>
          <div
            v-if="taxon"
            class="flex-separate middle"
          >
            <span
              class="margin-small-right"
              v-html="taxon.label_html"
            />
            <span
              class="button circle-button btn-undo button-default"
              @click="taxon = undefined"
            />
          </div>
          <template v-else>
            <VAutocomplete
              url="/taxon_names/autocomplete"
              autofocus
              label="label"
              min="2"
              clear-after
              placeholder="Select a taxon name"
              param="term"
              @get-item="(item) => (taxon = item)"
            />
          </template>
        </div>
        <button
          class="button normal-input button-submit"
          :disabled="!otuName"
          type="button"
          @click="
            () =>
              createOtu({
                taxonId: taxon ? taxon.id : undefined,
                name: otuName
              })
          "
        >
          Create
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import VAutocomplete from '@/components/ui/Autocomplete.vue'
import MatchTaxonName from './matchTaxonNames'
import { Otu } from '@/routes/endpoints'
import { ref, watch } from 'vue'

defineProps({
  inputId: {
    type: String,
    default: undefined
  },
  clearAfter: {
    type: Boolean,
    default: false
  },
  inputAttributes: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['get-item', 'get-input'])
const foundSomething = ref(true)

const otuName = ref()
const taxon = ref()
const type = ref()
const create = ref()

watch(type, (newVal, oldVal) => {
  if (newVal !== oldVal) {
    resetPicker()
    otuName.value = newVal
    foundSomething.value = true
    emit('get-input', newVal)
  }
})

function emitOtu({ id }) {
  Otu.find(id).then(({ body }) => {
    emit('get-item', body)
  })
}

function createOtu({ taxonId, name }) {
  const payload = {
    otu: {
      name,
      taxon_name_id: taxonId
    }
  }

  Otu.create(payload).then(({ body }) => {
    emit('get-item', body)
    create.value = false
    foundSomething.value = true
  })
}

function resetPicker() {
  otuName.value = undefined
  create.value = false
}

function callbackInput(event) {
  type.value = event
  emit('get-input', event)
}
</script>
<style lang="scss">
.vue-otu-picker {
  position: relative;
  .new-otu-panel {
    position: relative;
    display: none;
    z-index: 50;
  }
  .close-panel {
    opacity: 0.5;
    position: absolute;
    top: 14px;
    right: 14px;
    cursor: pointer;
  }
  .create-otu-panel {
    display: none;
    position: absolute;
    top: 30px;
    z-index: 2001;
  }
  .match-otu-box {
    position: relative;
  }
  &:focus-within,
  &:hover {
    .create-otu-panel {
      display: flex;
    }
    .new-otu-panel {
      display: flex;
    }
  }
}
</style>
