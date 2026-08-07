<template>
  <div class="attribution-summary-content">
    <div v-if="attribution.license">
      <strong>License:</strong> {{ attribution.license }}
    </div>
    <div v-if="attribution.copyright_year">
      <strong>Copyright year:</strong> {{ attribution.copyright_year }}
    </div>
    <div v-if="rolesSummary.length">
      <strong>Roles:</strong>
      <ul class="no_bullets">
        <li
          v-for="(role, index) in rolesSummary"
          :key="index"
        >
          {{ role }}
        </li>
      </ul>
    </div>
    <div v-if="isEmpty">
      <em>No criteria specified</em>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  attribution: {
    type: Object,
    required: true
  }
})

const rolesSummary = computed(() => {
  const roles = props.attribution.roles_attributes || []

  return roles.map((role) => {
    const type = role.type?.replace('Attribution', '') || ''
    const name = role.organization_id
      ? role.object_tag
      : formatName(role) || formatName(role.person_attributes)

    return `${type}: ${name || 'Unknown'}`
  })
})

const isEmpty = computed(() => {
  const { license, copyright_year, roles_attributes } = props.attribution

  return !license && !copyright_year && !roles_attributes?.length
})

function formatName(person) {
  if (!person) return null

  const { last_name, first_name } = person

  return [last_name, first_name].filter(Boolean).join(', ') || null
}
</script>
