<template>
  <div
    v-if="attributionsList.length"
    class="full_width panel content margin-small-left"
  >
    <h3>Attributions</h3>
    <template
      v-for="(attribution, index) in attributionsList"
      :key="index"
    >
      <ul class="no_bullets">
        <li
          v-for="(persons, pIndex) in attribution"
          :key="pIndex"
        >
          <span v-html="persons" />
        </li>
        <li v-if="attributions[index].copyright_year">
          Copyright year: <b>{{ attributions[index].copyright_year }}</b>
        </li>
        <li v-if="attributions[index].license">
          License:
          <b>{{ licenses[attributions[index].license]?.name }}</b>
        </li>
      </ul>
    </template>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { capitalize } from '@/helpers/strings.js'
import { getFullName } from '@/helpers/people/people'
import { Attribution } from '@/routes/endpoints'

const ROLE_TYPES = [
  'creator_roles',
  'owner_roles',
  'copyright_holder_roles',
  'editor_roles'
]

const licenses = ref({})

Attribution.licenses().then(({ body }) => {
  licenses.value = body
})

const roleLabel = (role) =>
  capitalize(role.replace('_roles', '').replaceAll('_', ' '))

const props = defineProps({
  attributions: {
    type: Array,
    required: true
  }
})

const attributionsList = computed(() =>
  props.attributions.map((attr) =>
    ROLE_TYPES.map((role) =>
      attr[role]
        ? `${roleLabel(role)}: <b>${attr[role]
            .map((item) =>
              item?.person ? getFullName(item.person) : item.organization.name
            )
            .join('; ')}</b>`
        : []
    ).filter((arr) => arr.length)
  )
)
</script>
