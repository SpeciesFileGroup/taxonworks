<template>
  <div v-show="list.length">
    <transition-group
      class="table-entrys-list"
      name="list-complete"
      tag="ul"
    >
      <li
        v-for="item in list"
        :key="item.id"
        class="list-complete-item flex-separate middle"
      >
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
            <span v-html="'&nbsp;'" />
          </template>
        </span>
        <div class="horizontal-right-content middle gap-small">
          <a
            :href="`/sources/${item.origin_citation.source_id}/edit`"
            target="_blank"
            v-if="getCitation(item)"
            v-html="getCitation(item)"
          />
          <RadialAnnotator
            :global-id="item.global_id"
            @close="update()"
          />
          <VBtn
            v-if="getCitation(item)"
            icon
            color="destroy"
            variant="tonal"
            title="Remove citation"
            @click="removeCitation(item)"
          >
            <IconTrash class="w-4 h-4" />
          </VBtn>
          <VBtn
            v-if="edit"
            icon
            color="primary"
            variant="tonal"
            @click="$emit('edit', item)"
          >
            <IconPencil class="w-4 h-4" />
          </VBtn>
          <VBtn
            icon
            color="destroy"
            variant="tonal"
            @click="remove(item)"
          >
            <IconTrash class="w-4 h-4" />
          </VBtn>
        </div>
      </li>
    </transition-group>
  </div>
</template>

<script>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import IconTrash from '@/components/Icon/IconTrash.vue'
import IconPencil from '@/components/Icon/IconPencil.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

export default {
  components: {
    RadialAnnotator,
    VBtn,
    IconPencil,
    IconTrash
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
    composeLink(item, show) {
      return show.link + item[show.param]
    },
    isLink(show) {
      if (typeof show === 'string' || show instanceof String) {
        return false
      } else {
        return true
      }
    },
    update() {
      this.$emit('update')
    },
    remove(item) {
      if (
        window.confirm(
          `You're trying to delete this record. Are you sure you want to proceed?`
        )
      ) {
        this.$emit('delete', item)
      }
    },
    getCitation: function (item) {
      return item.hasOwnProperty('origin_citation')
        ? item.origin_citation.citation_source_body
        : undefined
    },
    sendCitation(sourceId, item) {
      let citation = {
        id: item.id,
        origin_citation_attributes: {
          id: item.hasOwnProperty('origin_citation')
            ? item.origin_citation.id
            : null,
          source_id: sourceId
        }
      }
      this.$emit('addCitation', citation)
    },
    removeCitation(item) {
      let citation = {
        id: item.id,
        origin_citation_attributes: {
          id: item.hasOwnProperty('origin_citation')
            ? item.origin_citation.id
            : null,
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
.pages:disabled {
  background-color: #f5f5f5;
}
</style>
