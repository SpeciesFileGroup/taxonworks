<template>
  <tr>
    <td class="author-column">
      <a
        v-html="author.cached"
        :href="`/people/${author.id}`"
      />
    </td>
    <td class="roles-column">{{ roles.join('\n') }}</td>
    <td>
      <VBtn
        v-if="roleSourcesCount"
        class="source-list-button"
        color="primary"
        medium
        @click="() => emit('sources')"
      >
        <span> Show ({{ roleSourcesCount }}) </span>
      </VBtn>
    </td>
    <td>{{ author.id }}</td>
    <td>
      <a
        target="blank"
        :href="`${RouteNames.UnifyPeople}?last_name=${author.last_name}`"
      >
        Unify
      </a>
    </td>
    <td class="horizontal-left-content gap-small">
      <RadialAnnotator
        type="annotations"
        :global-id="author.global_id"
      />
      <radial-object :global-id="author.global_id" />
      <VPin
        v-if="author.id"
        :object-id="author.id"
        :pluralize="false"
        type="Person"
      />
    </td>
  </tr>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import RadialObject from '@/components/radials/navigation/radial'
import { RouteNames } from '@/routes/routes'
import { SOURCE } from '@/constants'
import { computed } from 'vue'

const props = defineProps({
  author: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['sources'])

const roleSourcesCount = computed(
  () => props.author.roles.filter((r) => r.role_object_type === SOURCE).length
)

const roles = computed(() => [
  ...new Set(props.author.roles.map((r) => r.role_object_type))
])
</script>

<style scoped>
.author-column {
  min-width: 200px;
}

.roles-column {
  max-width: 120px;
  white-space: pre;
}

.source-list-button {
  min-width: 60px;
}
</style>
