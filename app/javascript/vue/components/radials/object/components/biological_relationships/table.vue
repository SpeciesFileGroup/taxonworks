<template>
  <div>
    <table class="vue-table">
      <thead>
        <tr>
          <th>Relationship</th>
          <th>Related</th>
          <th>Inverted</th>
          <th></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody">
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item">
          <td v-html="item.biological_association_object_id === metadata.object_id ? item.biological_relationship.inverted_name : item.biological_relationship.name"/>
          <td v-html="getSubjectOrObject(item)"/>
          <td>{{ item.biological_association_object_id === metadata.object_id }}</td>
          <td class="vue-table-options">
            <citation-count
              :object="item"
              :values="item.citations"
              target="biological_associations"
            />
            <span
              class="circle-button btn-edit"
              @click="$emit('edit', item)"/>
            <radial-annotator :global-id="item.global_id"/>
            <span
              class="circle-button btn-delete"
              @click="deleteItem(item)">Remove
            </span>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>
<script>

  import RadialAnnotator from 'components/radials/annotator/annotator.vue'
  import CitationCount from '../shared/citationsCount.vue'

  export default {
    components: {
      RadialAnnotator,
      CitationCount
    },
    props: {
      list: {
        type: Array,
        default: () => {
          return []
        }
      },
      metadata: {
        type: Object,
        required: true
      }
    },
    mounted() {
      this.$options.components['RadialAnnotator'] = RadialAnnotator
    },
    methods: {
      deleteItem(item) {
        if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
          this.$emit('delete', item)
        }
      },
      getSubjectOrObject(item) {
        if(item.biological_association_object_id == this.metadata.object_id) {
          return item.subject.object_tag
        }
        else {
          return item.object.object_tag
        }
      },
      getCitationString(object) {
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

  .vue-table {
    width: 100%;
    .vue-table-options {
      display: flex;
      flex-direction: row;
      justify-content: flex-end;
    }
    tr {
      cursor: default;
    }
  }

  .list-complete-item {
    justify-content: space-between;
    transition: all 0.5s, opacity 0.2s;
  }

  .list-complete-enter-active, .list-complete-leave-active {
    opacity: 0;
    font-size: 0px;
    border: none;
  }
</style>
