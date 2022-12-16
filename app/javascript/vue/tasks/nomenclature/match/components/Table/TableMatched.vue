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
          <span v-html="taxon.object_tag" /> {{ taxon.cached_author_year }}
        </td>
        <td>
          <template v-if="taxon.cached_is_valid">
            <span v-html="taxon.object_tag" /> {{ taxon.cached_author_year }}
          </template>
          <template v-if="validNames[taxon.cached_valid_taxon_name_id]">
            <span v-html="validNames[taxon.cached_valid_taxon_name_id].object_tag" />
            {{ validNames[taxon.cached_valid_taxon_name_id].cached_author_year }}
          </template>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
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

</script>
