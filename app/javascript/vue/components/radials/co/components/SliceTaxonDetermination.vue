<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>
    <div>
      <TaxonDeterminationForm @on-add="addTaxonDetermination" />
    </div>

    <div class="margin-large-top">
      <template v-if="collectionObjects.passed.length">
        <h3>Updated</h3>
        <ul>
          <li
            v-for="item in collectionObjects.passed"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
      <template v-if="collectionObjects.failed.length">
        <h3>Not updated</h3>
        <ul>
          <li
            v-for="item in collectionObjects.failed"
            :key="item.id"
          >
            <a
              :href="`${RouteNames.BrowseCollectionObject}?collection_object_id=${item.id}`"
              v-html="item.object_tag"
            />
          </li>
        </ul>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import { CollectionObject } from '@/routes/endpoints'
import TaxonDeterminationForm from '@/components/TaxonDetermination/TaxonDeterminationForm.vue'

const MAX_LIMIT = 50

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const collectionObjects = ref({ passed: [], failed: [] })

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

function addTaxonDetermination(determination) {
  const payload = {
    collection_object_query: props.parameters,
    collection_object: {
      taxon_determinations_attributes: [
        {
          day_made: determination.day_made,
          month_made: determination.month_made,
          year_made: determination.year_made,
          otu_id: determination.otu_id,
          roles_attributes: determination.roles_attributes
        }
      ]
    }
  }

  CollectionObject.batchUpdate(payload).then(({ body }) => {
    TW.workbench.alert.create(
      `${body.passed.length} taxon determination(s) were successfully added.`,
      'notice'
    )
  })
}
</script>
