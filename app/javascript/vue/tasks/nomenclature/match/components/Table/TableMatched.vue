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
        v-for="{ taxon, match } in list"
        :key="taxon.id"
      >
        <td>{{ match.join(', ') }}</td>
        <td>
          <a :href="makeBrowseNomenclatureLink(taxon.id)">
            <span v-html="taxon.cached_html" /> {{ taxon.cached_author_year }}
            {{ getTaxonNameStatus(taxon) }}
          </a>
        </td>
        <td v-html="taxon.cached_original_combination_html" />
        <td>
          <a
            v-if="validNames[taxon.cached_valid_taxon_name_id]"
            :href="makeBrowseNomenclatureLink(taxon.cached_valid_taxon_name_id)"
          >
            <span
              v-html="validNames[taxon.cached_valid_taxon_name_id].cached_html"
            />
            {{
              validNames[taxon.cached_valid_taxon_name_id].cached_author_year
            }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { RouteNames } from 'routes/routes'
import { getTaxonNameStatus } from 'helpers/taxon_names.js'
defineProps({
  list: {
    type: Array,
    required: true
  },

  validNames: {
    type: Object,
    default: () => ({})
  }
})

const makeBrowseNomenclatureLink = (id) =>
  `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`
</script>
