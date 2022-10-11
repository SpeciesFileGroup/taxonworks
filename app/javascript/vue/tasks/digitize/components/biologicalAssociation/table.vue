<template>
  <div>
    <table class="vue-table">
      <thead>
        <tr>
          <th>Relationship</th>
          <th>Related</th>
          <th>Citation</th>
          <th>
            <div class="horizontal-right-content">
              <lock-component v-model="settings.locked.biologicalAssociations" />
            </div>
          </th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <template
          v-for="(item, index) in list"
          :key="item.id">
          <tr class="list-complete-item">
            <td v-html="item.biological_relationship.name"/>
            <td v-html="item.object.object_tag"/>
            <td v-html="getCitationString(item)"/>
            <td>
              <div class="middle horizontal-right-content">
                <radial-annotator
                  v-if="item.global_id"
                  :global-id="item.global_id"/>
                <span
                  class="circle-button btn-delete"
                  :class="{ 'button-default': !item.id }"
                  @click="deleteItem(index)">
                  Remove
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
import LockComponent from 'components/ui/VLock/index.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'

export default {
  components: {
    RadialAnnotator,
    LockComponent
  },

  props: {
    list: {
      type: Array,
      default: () => []
    }
  },

  emits: ['delete'],

  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },

  methods: {
    deleteItem (item) {
      if (item.id) {
        if (window.confirm('You\'re trying to delete this record. Are you sure want to proceed?')) {
          this.$emit('delete', item)
        }
      } else {
        this.$emit('delete', item)
      }
    },

    getCitationString (object) {
      const citation = object?.origin_citation || object?.origin_citation_attributes

      if (citation) {
        const authorString = citation.source.cached_author_string

        return citation.source?.year
          ? `${authorString}, ${citation.source.year}`
          : authorString
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
