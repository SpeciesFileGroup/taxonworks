<template>
  <tr>
    <td class="author-column">
      <a
        v-html="author.cached"
        :href="`/people/${author.id}`"
      />
    </td>
    <td>
      <button
        v-if="author.roles[0]"
        class="button normal-input button-default"
        @click="() => emit('sources')"
      >
        Sources
      </button>
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
    <td class="horizontal-left-content">
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
import RadialAnnotator from '@/components/radials/annotator/annotator'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import RadialObject from '@/components/radials/navigation/radial'
import { RouteNames } from '@/routes/routes'

defineProps({
  author: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['sources'])
</script>

<style scoped>
.author-column {
  min-width: 200px;
}
</style>
