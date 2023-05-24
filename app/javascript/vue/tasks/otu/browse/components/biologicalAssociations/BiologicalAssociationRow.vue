<template>
  <tr>
    <td>
      <BiologicalAssociationRelated
        :item-id="row.subjectId"
        :item-type="row.subjectType"
        :current="row"
      />
    </td>
    <td v-html="row.subjectOrder" />
    <td v-html="row.subjectFamily" />
    <td v-html="row.subjectGenus" />
    <td v-html="row.subjectLabel" />
    <td>
      <a
        :href="`/biological_associations/${row.id}`"
        :title="`Edit`"
        v-html="row.biologicalPropertySubject"
      />
    </td>

    <td v-html="row.biologicalRelationship"></td>
    <td>
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
    <td v-html="row.objectLabel" />
    <td>
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
  </tr>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import BiologicalAssociationRelated from './BiologicalAssociationRelated.vue'

const props = defineProps({
  row: {
    type: Object,
    required: true
  }
})

const store = useStore()
</script>
