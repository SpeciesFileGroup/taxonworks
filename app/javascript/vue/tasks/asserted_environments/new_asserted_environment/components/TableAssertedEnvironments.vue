<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Object</th>
        <th>Object type</th>
        <th>Environment</th>
        <th>Citations</th>
        <th class="w-2">Object</th>
        <th class="w-2">Asserted environment</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.assertedEnvironments"
        :key="item.id"
      >
        <td>
          <a
            :href="browseObjectLink(item)"
            v-html="item.asserted_environment_object.object_tag"
          />
        </td>
        <td>
          {{ item.asserted_environment_object_type }}
        </td>
        <td>
          <a
            :href="item.uri"
            target="_blank"
          >
            {{ item.uri_label }}
          </a>
        </td>
        <td v-if="item.citations?.length > 1">
          <CitationCount
            :citations="item.citations"
            @delete="(c) => store.removeAssertedEnvironmentCitation(c)"
          />
        </td>
        <td v-else>
          <a
            v-if="item.citations?.length"
            target="blank"
            :href="nomenclatureBySourceRoute(item.citations[0].source_id)"
            v-html="item.citations[0].citation_source_body"
          />
        </td>
        <td>
          <QuickForms :global-id="item.asserted_environment_object.global_id" />
        </td>
        <td>
          <div class="flex-row gap-small">
            <RadialAnnotator
              type="annotations"
              :global-id="item.global_id"
            />
            <RadialNavigator :global-id="item.global_id" />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
// Written with CLAUDE code
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import CitationCount from '@/components/citations/CitationsCount.vue'
import QuickForms from '@/components/radials/object/radial.vue'

import { RouteNames } from '@/routes/routes'
import { useStore } from '../store/store'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import { toSnakeCase } from '@/helpers'

const store = useStore()

function nomenclatureBySourceRoute(id) {
  return `${RouteNames.NomenclatureBySource}?source_id=${id}`
}

function browseObjectLink(item) {
  const model = item.asserted_environment_object_type
  const browseLink = RouteNames[`Browse${model}`]

  return browseLink
    ? `${browseLink}?${ID_PARAM_FOR[model]}=${item.asserted_environment_object_id}`
    : `/${toSnakeCase(model)}s/${item.asserted_environment_object_id}`
}
</script>

<style scoped>
table,
td,
tr {
  position: relative !important;
}
</style>
