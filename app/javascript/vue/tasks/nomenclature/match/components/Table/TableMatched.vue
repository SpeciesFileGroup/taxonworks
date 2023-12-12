<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Original</th>
        <th>Match</th>
        <th>Original combination</th>
        <th>Valid name</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="data in list"
        :key="data.line"
      >
        <td>{{ data.line }}</td>
        <td>
          <template
            v-for="taxon in data.taxon"
            :key="taxon.id"
          >
            <a :href="makeBrowseNomenclatureLink(taxon.id)">
              <span v-html="taxon.cached_html" /> {{ taxon.cached_author_year }}
              {{ getTaxonNameStatus(taxon) }}
            </a>
            <br />
          </template>
        </td>
        <td>
          <template
            v-for="taxon in data.taxon"
            :key="taxon.id"
          >
            <span v-html="taxon.cached_original_combination_html" />
            <br />
          </template>
        </td>
        <td>
          <a :href="makeBrowseNomenclatureLink(data.validTaxon.id)">
            <span v-html="data.validTaxon.cached_html" />
            {{ data.validTaxon.cached_author_year }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { getTaxonNameStatus } from '@/helpers/taxon_names.js'
defineProps({
  list: {
    type: Object,
    required: true
  }
})

const makeBrowseNomenclatureLink = (id) =>
  `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
</script>
