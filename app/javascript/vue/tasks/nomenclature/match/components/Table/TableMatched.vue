<template>
  <table class="table-striped">
    <thead>
      <tr>
        <th>Original</th>
        <th>Match</th>
        <th>Valid name</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="({ taxon, match }) in list"
        :key="taxon.id"
      >
        <td>{{ match }}</td>
        <td>
          <a :href="makeBrowseNomenclatureLink(taxon.id)">
            <span v-html="taxon.object_tag" /> {{ taxon.cached_author_year }}
          </a>
        </td>
        <td>
          <a
            v-if="taxon.cached_is_valid"
            :href="makeBrowseNomenclatureLink(taxon.id)"
          >
            <span v-html="taxon.object_tag" /> {{ taxon.cached_author_year }}
          </a>

          <a
            v-if="validNames[taxon.cached_valid_taxon_name_id]"
            :href="makeBrowseNomenclatureLink(taxon.cached_valid_taxon_name_id)"
          >
            <span v-html="validNames[taxon.cached_valid_taxon_name_id].object_tag" />
            {{ validNames[taxon.cached_valid_taxon_name_id].cached_author_year }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { RouteNames } from 'routes/routes'
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

const makeBrowseNomenclatureLink = (id) => `${RouteNames.BrowseNomenclature}?taxon_name_id=${id}`

</script>
