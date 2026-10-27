<template>
  <div class="full_width">
    <table class="table-striped full_width">
      <thead>
        <tr>
          <th>Subject</th>
          <th>Relationship</th>
          <th>Object</th>
          <th>Citations</th>
          <th class="w-2" />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="item in list"
          :key="item.id"
        >
          <td v-html="item.subject.object_tag" />
          <td v-html="item.relationship.object_tag" />
          <td v-html="item.object.object_tag" />
          <td v-if="item.citations.length > 1">
            <CitationsCount
              :citations="item.citations"
              @delete="(c) => store.removeBiologicalAssociationCitation(c)"
            />
          </td>
          <td v-else-if="item.citations.length">
            <a
              target="blank"
              :href="nomenclatureBySourceRoute(item.citations[0].source_id)"
              v-html="item.citations[0].citation_source_body"
            />
          </td>
          <td v-else />
          <td>
            <div class="flex-row gap-small">
              <RadialAnnotator :global-id="item.global_id" />
              <RadialObject :global-id="item.global_id" />
              <RadialNavigator
                :global-id="item.global_id"
                :redirect="false"
                @delete="(item) => emit('remove', item)"
              />
              <VBtn
                circle
                color="primary"
                @click="() => emit('select', item)"
              >
                <VIcon
                  x-small
                  name="pencil"
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import CitationsCount from '@/components/citations/CitationsCount.vue'
import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/store.js'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['select', 'remove'])

const store = useStore()

function nomenclatureBySourceRoute(sourceId) {
  return `${RouteNames.NomenclatureBySource}?source_id=${sourceId}`
}
</script>
