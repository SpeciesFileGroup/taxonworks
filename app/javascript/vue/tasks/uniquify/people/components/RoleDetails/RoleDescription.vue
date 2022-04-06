<template>
  <v-modal
    :container-style="{ width: '600px' }"
    @close="emit('close')"
  >
    <template #header>
      <h3>{{ title }} ({{ roleType }} roles)</h3>
    </template>
    <template #body>
      <RoleLegend />
      <table class="full_width margin-large-top">
        <tr
          v-for="item in objects"
          :key="item.id"
          class="contextMenuCells row-role"
          :class="classForRoleProject(roles.find(r => r.role_object_id === item.id))"
        >
          <td v-html="item.object_tag" />
        </tr>
      </table>
      <p
        v-if="nothingFound"
        class="horizontal-center-content"
      >
        No results found in project
      </p>
      <v-spinner v-if="isLoading" />
    </template>
  </v-modal>
</template>

<script setup>
import { computed } from 'vue'
import RoleLegend from './RoleLegend.vue'
import VModal from 'components/ui/Modal.vue'
import VSpinner from 'components/spinner.vue'
import useRoleObjectRequest from '../../composables/useRoleObjectRequest.js'

const props = defineProps({
  roleType: {
    type: String,
    required: true
  },

  roles: {
    type: Array,
    required: true
  },

  title: {
    type: String,
    required: true
  }
})

const emit = defineEmits('close')

const [isLoading, objects] = useRoleObjectRequest(props.roles)
const nothingFound = computed(() => !isLoading.value && !objects.value.length)

const classForRoleProject = role => {
  if (!role.project_id) { return 'community' }
  if (role.in_project) { return 'in-project' }

  return 'no-in-project'
}

</script>

<style lang="scss" scoped>
@import './RoleDescription.scss';
.row-role {
  border-left: 4px solid;
}
.community {
  border-left-color: $color-community;
}
.in-project {
  border-left-color: $color-in-project;
}
.no-in-project {
  border-left-color: $color-no-in-project;
}
</style>
