<template>

  <div>
    <div>
      Enter the shapefile field containing Gazetteer names or
      <VBtn
        color="primary"
        medium
        @click="() => lookupShapefileFieldsForName()"
      >
        Select from shapefile fields
      </VBtn>
    </div>
    <div class="field-input">
      <input
        type="text"
        class="normal-input name-input"
        v-model="shapeNameField"
      />
    </div>

    <div>
      Enter the shapefile field containing Iso 3166 a2 codes or
      <VBtn
        color="primary"
        medium
        @click="() => lookupShapefileFieldsForIsoA2()"
      >
        Select from shapefile fields
      </VBtn>
    </div>
    <div class="field-input">
      <input
        type="text"
        class="normal-input name-input"
        v-model="shapeIsoA2Field"
      />
    </div>

    <div>
      Enter the shapefile field containing Iso 3166 a3 codes or
      <VBtn
        color="primary"
        medium
        @click="() => lookupShapefileFieldsForIsoA3()"
      >
        Select from shapefile fields
      </VBtn>
    </div>
    <div class="field-input">
      <input
        type="text"
        class="normal-input name-input"
        v-model="shapeIsoA3Field"
      />
    </div>
  </div>

  <VModal
    v-if="modalVisible"
    @close="() => {
      modalVisible = false
      modalSelection = ''
      modalAssigneeRef = null
    }"
  >
    <template #header>
      <h3>Shapefile fields</h3>
    </template>
    <template #body>
      <ul class="no_bullets">
        <li
          v-for="f in shapefileFields"
          :key="f"
        >
          <label >
            <input
              type="radio"
              name="modal_fields"
              :value="f"
              v-model="modalSelection"
            />
            {{ f }}
          </label>
        </li>
      </ul>
      <VBtn
        :disabled="!modalSelection"
        medium
        color="primary"
        @click="() => setShapefileField()"
        class="modal-button"
      >
        Select name field
      </VBtn>
    </template>
  </VModal>

</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VModal from '@/components/ui/Modal.vue'
import { Gazetteer } from '@/routes/endpoints'
import { ref } from 'vue'

const shapeNameField = defineModel('name')
const shapeIsoA2Field = defineModel('isoA2')
const shapeIsoA3Field = defineModel('isoA3')
const isLoading = defineModel('isLoading')

const shapefileFields = ref([])
const modalVisible = ref(false)
const modalSelection = ref('')

// The ref assigned to by user selection of a shapefile field in the modal
let modalAssigneeRef = null

const props = defineProps({
  shpDoc: {
    type: Object,
    default: null
  },
  dbfDoc: {
    type: Object,
    default: null
  }
})

function lookupShapefileFieldsForName() {
  lookupShapefileFieldsFor(shapeNameField)
}

function lookupShapefileFieldsForIsoA2() {
  lookupShapefileFieldsFor(shapeIsoA2Field)
}

function lookupShapefileFieldsForIsoA3() {
  lookupShapefileFieldsFor(shapeIsoA3Field)
}

function lookupShapefileFieldsFor(field) {
  if (!props.shpDoc && !props.dbfDoc) {
    TW.workbench.alert.create(
      'Select a .shp (or .dbf) document first.', 'error'
    )
    return
  }

  const payload = {
    shp_doc_id: props.shpDoc?.id,
    dbf_doc_id: props.dbfDoc?.id
  }
  isLoading.value = true
  modalVisible.value = true
  Gazetteer.shapefile_fields(payload)
    .then(({ body }) => {
      shapefileFields.value = body.shapefile_fields
      modalAssigneeRef = field
    })
    .catch(() => {
      modalVisible.value = false
    })
    .finally(() => {
      isLoading.value = false
    })
}

function setShapefileField() {
  modalAssigneeRef.value = modalSelection.value
  modalVisible.value = false
  modalSelection.value = ''
  modalAssigneeRef = null
}

</script>

<style lang="scss" scoped>

.modal-button {
  margin-top: 1.5em;
}

.field-input {
  margin-bottom: 1.5em;
}

</style>