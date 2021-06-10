<template>
  <div>
    <table class="vue-table">
      <thead>
        <tr>
          <th>Relationship</th>
          <th>Related</th>
          <th>Citation</th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <template v-for="(item, index) in list">
          <tr
            v-if="item.hasOwnProperty('id')"
            :key="item.id"
            class="list-complete-item">
            <td v-html="item.biological_relationship.name"/>
            <td v-html="item.object.object_tag"/>
            <td v-html="getCitationString(item)"/>
            <td class="vue-table-options">
              <radial-annotator :global-id="item.global_id"/>
              <span
                class="circle-button btn-delete"
                @click="deleteItem(item)">Remove
              </span>
            </td>
          </tr>
          <tr
            v-else
            :key="`${item.biologicalRelationship.id}${item.biologicalRelation.id}`">
            <td v-html="item.biologicalRelationship.name"/>
            <td v-html="item.biologicalRelation.object_tag"/>
            <td v-html="getCitationString(item)"/>
            <td>
              <span
                class="circle-button btn-delete btn-default"
                @click="$emit('delete', index)">Remove
              </span>
            </td>
          </tr>
        </template>
      </transition-group>
    </table>
  </div>
</template>
<script>

import RadialAnnotator from 'components/radials/annotator/annotator.vue'

export default {
  components: {
    RadialAnnotator
  },

  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  emits: ['delete'],

  mounted () {
    this.$options.components['RadialAnnotator'] = RadialAnnotator
  },

  methods: {
    deleteItem(item) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('delete', item)
      }
    },
    getCitationString(object) {
      if(object.hasOwnProperty('citation') && object.citation) {
        return object.citation.label
      }
      if(object.hasOwnProperty('origin_citation')) {
        let citation = object.origin_citation.source.cached_author_string
        if(object.origin_citation.source.hasOwnProperty('year'))
          citation = citation + ', ' + object.origin_citation.source.year
        return citation
      }
      return ''
    }
  }
}
</script>
<style lang="scss" scoped>
  :deep(.otu_tag_taxon_name) {
    white-space: normal !important;
  }
</style>
