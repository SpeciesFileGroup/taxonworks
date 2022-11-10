<template>
  <div v-show="list.length">
    <transition-group
      class="table-entrys-list"
      name="list-complete"
      tag="ul">
      <li
        v-for="(item) in list"
        :key="item.id"
        class="list-complete-item flex-separate middle">
        <span class="list-item">
          <template v-for="show in display">
            <span v-if="isLink(show)">
              <a
                target="_blank"
                :href="composeLink(item, show)"
                v-html="item[show.label]"
              />
            </span>
            <span
              v-else
              v-html="item[show]"
            />
          </template>
        </span>
        <div class="list-controls">
          <a
            :href="`/sources/${item.origin_citation.source_id}/edit`"
            target="_blank"
            v-if="getCitation(item)"
            v-html="getCitation(item)"/>
          <radial-annotator
            @close="update()"
            :global-id="item.global_id"/>
          <span
            type="button"
            title="Remove citation"
            class="circle-button button-delete btn-undo"
            v-if="getCitation(item)"
            @click="removeCitation(item)"/>
          <span
            v-if="edit"
            type="button"
            class="circle-button btn-edit"
            @click="$emit('edit', item)"/>
          <span
            type="button"
            class="circle-button btn-delete"
            @click="remove(item)">Remove
          </span>
        </div>
      </li>
    </transition-group>
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
    },
    display: {
      type: Array
    },
    edit: {
      type: Boolean,
      default: false
    }
  },
  name: 'ListEntrys',
  methods: {
    composeLink (item, show) {
      return show.link + item[show.param]
    },
    isLink (show) {
      if (typeof show === 'string' || show instanceof String) {
        return false
      } else {
        return true
      }
    },
    update () {
      this.$emit('update')
    },
    remove(item) {
      if(window.confirm(`You're trying to delete this record. Are you sure want to proceed?`)) {
        this.$emit('delete', item)
      }
    },
    getCitation: function (item) {
      return (item.hasOwnProperty('origin_citation') ? item.origin_citation.citation_source_body : undefined)
    },
    sendCitation (sourceId, item) {
      let citation = {
        id: item.id,
        origin_citation_attributes: {
          id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
          source_id: sourceId
        }
      }
      this.$emit('addCitation', citation)
    },
    removeCitation (item) {
      let citation = {
        id: item.id,
        origin_citation_attributes: {
          id: (item.hasOwnProperty('origin_citation') ? item.origin_citation.id : null),
          _destroy: true
        }
      }
      this.$emit('addCitation', citation)
    }
  }
}
</script>

<style lang="scss" scoped>
.pages {
  margin-left: 8px;
  width: 70px;
}
.list-controls {
  display: flex;
  align-items:center;
  flex-direction:row;
  justify-content: flex-end;
  width: 550px;
}
.pages:disabled {
  background-color: #F5F5F5;
}

.list-item {
  span {
    margin-right: 4px;
  }
}

.table-entrys-list {
  padding: 0px;
  position: relative;

  li {
    margin: 0px;
    padding: 1em 0;
    border-bottom: 1px solid #f5f5f5;
  }
}
.list-complete-item {
  transition: all 1s, opacity 0.2s;

}
.list-complete-enter, .list-complete-leave-to
{
  opacity: 0;
  font-size: 0px;
  border:none;
  transform: scale(0.0);
}
.list-complete-leave-active {
  width: 100%;
  position: absolute;
}
</style>
