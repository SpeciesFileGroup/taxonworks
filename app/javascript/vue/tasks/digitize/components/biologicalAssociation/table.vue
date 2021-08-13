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
        <template
          v-for="(item, index) in list"
          :key="item.id">
          <tr
            v-if="item.id"
            class="list-complete-item">
            <td v-html="item.biological_relationship.name"/>
            <td v-html="item.object.object_tag"/>
            <td v-html="getCitationString(item)"/>
            <td>
              <div class="middle horizontal-right-content">
                <radial-annotator :global-id="item.global_id"/>
                <span
                  class="circle-button btn-delete"
                  @click="deleteItem(index)">Remove
                </span>
              </div>
            </td>
          </tr>
          <tr v-else>
            <td v-html="item.biologicalRelationship.name"/>
            <td v-html="item.biologicalRelation.object_tag"/>
            <td v-html="getCitationString(item)"/>
            <td>
              <div class="horizontal-right-content middle">
                <span
                  class="circle-button btn-delete btn-default"
                  @click="$emit('delete', index)">Remove
                </span>
              </div>
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
  components: { RadialAnnotator },

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
    deleteItem (item) {
      if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
        this.$emit('delete', item)
      }
    },

    getCitationString(object) {
      if (object?.citation) {
        return object.citation.label
      } else if(object.hasOwnProperty('origin_citation')) {
        const citation = object.origin_citation.source.cached_author_string

        return object.origin_citation.source.hasOwnProperty('year')
          ? `${citation}, ${object.origin_citation.source.year}`
          : citation
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
