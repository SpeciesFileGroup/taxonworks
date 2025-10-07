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
          :key="oid"
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

    <table
      v-if="ontologies.length > 0"
      class="table-striped"
    >
      <thead>
        <tr>
          <th></th>
          <th>ID</th>
          <th>Title</th>
          <th>Description</th>
        </tr>
      </thead>

      <tbody>
        <template
          v-for="(o) in ontologies"
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
import { addToArray, removeFromArray } from '@/helpers'
import { AnatomicalPart } from '@/routes/endpoints'
import { onMounted, ref } from 'vue'
import { getCurrentProjectId } from '@/helpers/project.js'

const projectId = Number(getCurrentProjectId())
const ontologies = ref([])
const selectedOntologies = ref([])
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
    ontology_oids: selectedOntologies.value.map((o) => o.oid)
  }

  AnatomicalPart.saveOntologyIdsToProject(payload)
}

onMounted(async () => {
  isLoading.value = true
  const preferenceOids = null

  try {
    const [a, b] = await Promise.allSettled([
      AnatomicalPart.ontologies()
        .then(({ body }) => (ontologies.value = body)),

      AnatomicalPart.ontologyIdPreferences({ project_id: projectId })
        .then(({ body }) => {
          preferenceOids = body
      })
    ])

    if (a.status == 'fulfilled' && b.status == 'fulfilled') {
      preferenceOids.forEach((poid) => {
        let i = -1
        if ((i = ontologies.value.findIndex((o => o.oid == poid))) != -1) {
          selectedOntologies.value.push(ontologies.value[i])
        }
      })
    }
  } finally {
    isLoading.value = false
  }

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