<template>
  <div>
    <h1>Project organizations</h1>
    <p>
      The organizations associated with this project. Images are added to an
      organization with the radial annotator.
    </p>

    <div class="panel content separate-bottom">
      <OrganizationPicker @select="addOrganization" />
    </div>

    <div class="panel content">
      <VSpinner v-if="isLoading" />
      <OrganizationTable
        :project-organizations="projectOrganizations"
        @remove="removeProjectOrganization"
        @refresh="refreshProjectOrganization"
      />
    </div>
  </div>
</template>

<script setup>
import OrganizationPicker from '@/components/organizationPicker.vue'
import OrganizationTable from './components/OrganizationTable.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { ProjectOrganization } from '@/routes/endpoints'
import { onBeforeMount, ref } from 'vue'

const projectOrganizations = ref([])
const isLoading = ref(false)

function loadProjectOrganizations() {
  isLoading.value = true

  ProjectOrganization.all()
    .then(({ body }) => {
      projectOrganizations.value = body
    })
    .finally(() => {
      isLoading.value = false
    })
}

function addOrganization(organization) {
  ProjectOrganization
    .create({
      project_organization: { organization_id: organization.id }
    })
    .then(({ body }) => {
      projectOrganizations.value.push(body)
      TW.workbench.alert.create(
        'Organization was successfully added to the project.',
        'notice'
      )
    })
    .catch(() => {})
}

// Depictions are added with the radial annotator, so the row is reloaded when it closes
function refreshProjectOrganization(projectOrganization) {
  ProjectOrganization
    .find(projectOrganization.id)
    .then(({ body }) => {
      const index = projectOrganizations.value.findIndex(
        (item) => item.id === body.id
      )

      projectOrganizations.value[index] = body
    })
    .catch(() => {})
}

function removeProjectOrganization(projectOrganization) {
  ProjectOrganization
    .destroy(projectOrganization.id).then(() => {
      projectOrganizations.value = projectOrganizations.value.filter(
        (item) => item.id !== projectOrganization.id
      )
      TW.workbench.alert.create(
        'Organization was successfully removed from the project.',
        'notice'
      )
    })
    .catch(() => {})
}

onBeforeMount(loadProjectOrganizations)
</script>
