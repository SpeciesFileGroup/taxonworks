<template>
  <tr>
    <td>
      <div class="flex-row gap-small">
        <RadialAnnotator :global-id="row.globalId" />
        <RadialNavigator :global-id="row.globalId" />
      </div>
    </td>
    <td class="table-cell-border-left-thick">
      <BiologicalAssociationRelated
        :item-id="row.subjectId"
        :item-type="row.subjectType"
        :current="row"
      />
    </td>
    <td v-html="row.subjectOrder" />
    <td v-html="row.subjectFamily" />
    <td v-html="row.subjectGenus" />
    <td>
      <a
        :href="makeBrowseUrl({ id: row.subjectId, type: row.subjectType })"
        v-html="row.subjectTag"
      />
    </td>
    <td>
      <a
        :href="`/biological_associations/${row.id}`"
        :title="`Edit`"
        v-html="row.biologicalPropertySubject"
      />
    </td>

    <td
      class="table-cell-border-left-thick"
      v-html="row.biologicalRelationship"
    />
    <td class="table-cell-border-left-thick">
      <a
        :href="`/biological_associations/${row.id}`"
        :title="`Edit`"
        v-html="row.biologicalPropertyObject"
      />
    </td>

    <td>
      <BiologicalAssociationRelated
        :item-id="row.objectId"
        :item-type="row.objectType"
        :current="row"
      />
    </td>
    <td v-html="row.objectOrder" />
    <td v-html="row.objectFamily" />
    <td v-html="row.objectGenus" />
    <td>
      <a
        :href="makeBrowseUrl({ id: row.objectId, type: row.objectType })"
        v-html="row.objectTag"
      />
    </td>
    <td class="table-cell-border-left-thick">
      <template
        v-for="(citation, index) in row.citations"
        :key="citation.id"
      >
        <a
          :href="`/tasks/nomenclature/by_source?source_id=${citation.source_id}`"
          :title="`${citation.source.cached}`"
          v-html="citation.label"
        />
        <span v-if="index < row.citations.length - 1">; </span>
      </template>
    </td>
    <td>
      <span
        v-for="tag in row.tags"
        :key="tag.id"
        v-html="tag.label"
      />
    </td>
  </tr>
</template>

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import BiologicalAssociationRelated from './BiologicalAssociationRelated.vue'
import { makeBrowseUrl } from '@/helpers'

defineProps({
  row: {
    type: Object,
    required: true
  }
})
</script>
