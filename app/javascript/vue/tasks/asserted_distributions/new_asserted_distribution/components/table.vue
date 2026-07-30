<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Object</th>
        <th>Object type</th>
        <th>Shape</th>
        <th>Citations</th>
        <th class="w-2">OTU</th>
        <th class="w-2">AD</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="item in store.assertedDistributions"
        :key="item.id"
      >
        <td>
          <a
            v-if="browseObjectLink(item)"
            :href="browseObjectLink(item)"
            v-html="item.asserted_distribution_object.object_tag"
          />
          <span v-else>
            {{ item.asserted_distribution_object_type }}
          </span>
        </td>
        <td>
          {{ item.asserted_distribution_object_type }}
        </td>
        <td
          v-html="
            shapeLink(
              item.asserted_distribution_shape,
              item.asserted_distribution_shape_type
            )
          "
        />
        <td v-if="item.citations.length > 1">
          <CitationCount
            :citations="item.citations"
            @delete="(c) => store.removeAssertedDistributionCitation(c)"
          />
        </td>
        <td v-else>
          <div class="middle">
            <a
              class="margin-small-right"
              target="blank"
              :href="nomenclatureBySourceRoute(item.citations[0].source_id)"
              v-html="item.citations[0].citation_source_body"
            />
            <SoftValidation :global-id="item.global_id" />
          </div>
        </td>

        <td>
          <QuickForms
            :global_id="item.asserted_distribution_object.global_id"
          />
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
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import CitationCount from '@/components/citations/CitationsCount.vue'
import SoftValidation from '@/components/soft_validations/objectValidation.vue'
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
  const model = item.asserted_distribution_object_type
  const browseTask = `Browse${model}`
  const browseLink = RouteNames[browseTask]
  if (browseLink) {
    return `${browseLink}?${ID_PARAM_FOR[model]}=${item.asserted_distribution_object_id}`
  } else {
    return `/${toSnakeCase(model)}s/${item.asserted_distribution_object_id}`
  }
}

function shapeLink(shape, type) {
  if (type == 'GeographicArea') {
    return `<a href="/geographic_areas/${shape.id}">${shape.name}</a>`
  } else {
    return `<a href="/gazetteers/${shape.id}">${shape.name}</a>`
  }
}
</script>
<style scoped>
table,
td,
tr {
  position: relative !important;
}
</style>
