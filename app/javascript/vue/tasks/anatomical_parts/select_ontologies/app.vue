<template>
  <div>
    <VSpinner
      v-if="isLoading"
    />

    <h2>
      Select up to 3 ontologies from which ontology classes can be selected
      during Anatomical Part creation.
    </h2>

    <fieldset class="margin-large-bottom">
      <legend>Selected ontologies</legend>
      <ol
        v-if="selectedOntologies.length > 0"
        class="o-list"
      >
        <template
          v-for="(o, i) in selectedOntologies"
          :key="o.oid"
        >
          <li class="horizontal-left-content gap-xsmall">
            <span>{{ `${i + 1}. ${o.oid}: ${o.title}` }}</span>
            <VBtn
              class="circle-button"
              color="destroy"
              @click="removeOntology(o)"
            >
              <VIcon
                name="trash"
                x-small
              />
            </VBtn>
          </li>
        </template>
      </ol>

      <p v-else>
        <i>No ontologies selected.</i>
      </p>
    </fieldset>

    <div class="margin-medium-bottom">
      See <a href="https://www.ebi.ac.uk/ols4/ontologies">https://www.ebi.ac.uk/ols4/ontologies</a> for further information on available ontologies.
    </div>

    <div>
      {{ filteredOntologies.length }}
      {{ filteredOntologies.length == 1 ? 'ontology' : 'ontologies' }}
    </div>
    <table
      class="table-striped full_width"
    >
      <thead>
        <tr>
          <th />
          <th>ID</th>
          <th>Title</th>
          <th>Description</th>
        </tr>

        <tr>
          <th />
          <th>
            <input
              v-model="idText"
              placeholder="Filter ID"
              @input="filterTable"
            />
          </th>
          <th>
            <input
              v-model="titleText"
              placeholder="Filter title"
              @input="filterTable"
            />
          </th>
          <th>
            <input
              v-model="descriptionText"
              placeholder="Filter description"
              @input="filterTable"
            />
          </th>
        </tr>
      </thead>

      <tbody>
        <template
          v-for="(o) in filteredOntologies"
          :key="o.oid"
        >
          <tr>
            <td>
              <VBtn
                v-if="!selectedOntologies.includes(o)"
                color="submit"
                @click="() => selectOntology(o)"
              >
                Select
              </VBtn>

              <VBtn
                v-else
                color="destroy"
                @click="() => removeOntology(o)"
              >
                De-select
              </VBtn>
            </td>
            <td>{{ o.oid }}</td>
            <td>{{ o.title }}</td>
            <td>{{ o.description }}</td>
          </tr>
        </template>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { addToArray, intersectArrays, removeFromArray } from '@/helpers'
import { AnatomicalPart } from '@/routes/endpoints'
import { onMounted, ref } from 'vue'
import { getCurrentProjectId } from '@/helpers/project.js'

const projectId = Number(getCurrentProjectId())
const ontologies = ref([])
const filteredOntologies = ref([])
const selectedOntologies = ref([])
const idText = ref('')
const titleText = ref('')
const descriptionText = ref('')
const isLoading = ref(false)

function selectOntology(o) {
  if (selectedOntologies.value.length == 3) {
    TW.workbench.alert.create('There are already 3 ontologies saved - remove one to choose a different one.', 'notice')
    return
  }
  addToArray(selectedOntologies.value, o, { property: 'oid' })
  saveToProject()
}

function removeOntology(o) {
  removeFromArray(selectedOntologies.value, o, { property: 'oid' })
  saveToProject()
}

function saveToProject() {
  const payload = {
    project_id: projectId,
    ontologies: selectedOntologies.value.map((o) => ({
      oid: o.oid,
      title: o.title
    })
  )}

  AnatomicalPart.saveOntologiesToProject(payload)
}

function filterTable() {
  if (!idText.value && !titleText.value && !descriptionText.value) {
    filteredOntologies.value = ontologies.value
    return
  }

  let idMatches = ontologies.value
  if (!!idText) {
    idMatches = []
    ontologies.value.forEach((o) => {
      if (o.oid.toLowerCase().includes(idText.value)) {
        idMatches.push(o)
      }
    })
  }

  let titleMatches = ontologies.value
  if (!!titleText) {
    titleMatches = []
    ontologies.value.forEach((o) => {
      if (o.title.toLowerCase().includes(titleText.value)) {
        titleMatches.push(o)
      }
    })
  }

  let descriptionMatches = ontologies.value
  if (!!descriptionText) {
    descriptionMatches = []
    ontologies.value.forEach((o) => {
      if (o.description.toLowerCase().includes(descriptionText.value)) {
        descriptionMatches.push(o)
      }
    })
  }

  filteredOntologies.value =
    intersectArrays(idMatches, titleMatches, descriptionMatches)
}

onMounted(() => {
  isLoading.value = true
  Promise.all([
    AnatomicalPart.ontologies()
      .catch(() => {}),

    AnatomicalPart.ontologyPreferences({ project_id: projectId })
      .catch(() => {})
  ])
  .then((values) => {
    ontologies.value = values[0].body
    filteredOntologies.value = ontologies.value

    values[1].body.forEach((ontology) => {
      let i
      if ((i = ontologies.value.findIndex((o => o.oid == ontology.oid))) != -1) {
        selectedOntologies.value.push(ontologies.value[i])
      }
    })
  })
  .finally(() => isLoading.value = false)
})

</script>

<style scoped>
.o-list {
  line-height: 2.5;
  font-size: 130%;
}

.o-list flex {
  align-items: bottom;
}
</style>