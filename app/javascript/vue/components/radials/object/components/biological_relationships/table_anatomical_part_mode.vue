<template>
  <div>
    <table class="vue-table">
      <thead>
        <tr>
          <th class="subject-col">Subject</th>
          <th class="relationship-col">Relationship</th>
          <th class="related-col">Related</th>
          <th class="inverted-col">Inverted</th>
          <th class="actions-col"></th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <tr
          v-for="item in list"
          :key="item.id"
          class="list-complete-item"
        >
          <td class="subject-col">
            <VBtn
              v-if="item.subject_anatomical_part?.name"
              medium
              color="primary"
              class="btn-pill-left subject-pill name-pill"
              :title="item.subject_anatomical_part.name"
            >
              <span class="subject-name">{{ item.subject_anatomical_part.name }}</span>
            </VBtn>
            <VBtn
              v-else
              medium
              color="primary"
              class="btn-pill-left subject-pill uri-pill"
              :title="uriPillTitle(item)"
            >
              <span class="subject-uri-label">{{ item.subject_anatomical_part?.uri_label }}</span>
            </VBtn>
          </td>
          <td
            class="relationship-col"
            v-html="item.biological_relationship.object_tag"
          />
          <td
            class="related-col"
            :title="item.object?.object_label || ''"
            v-html="item.object?.object_tag"
          />
          <td class="inverted-col">
            {{ item.biological_association_object_id === props.metadata.object_id }}
          </td>
          <td class="actions-col">
            <div class="horizontal-right-content gap-xsmall">
              <citation-count
                :object="item"
                :values="item.citations"
                target="biological_associations"
              />
              <RadialAnnotator :global-id="item.global_id" />
              <RadialObject :global-id="item.global_id" />
              <RadialNavigator :global-id="item.global_id" />

              <VBtn
                circle
                :color="softDelete ? 'primary' : 'destroy'"
                @click="deleteItem(item, index)"
              >
                <VIcon
                  name="trash"
                  x-small
                />
              </VBtn>
            </div>
          </td>
        </tr>
      </transition-group>
    </table>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import CitationCount from '../shared/citationsCount.vue'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  metadata: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['delete'])

function deleteItem(item) {
  if (
    window.confirm(
      "You're trying to delete this record. Are you sure want to proceed?"
    )
  ) {
    emit('delete', item)
  }
}

function uriPillTitle(item) {
  const label = item.subject_anatomical_part?.uri_label
  const uri = item.subject_anatomical_part?.uri

  return [label, uri].filter(Boolean).join('\n')
}
</script>

<style lang="scss" scoped>
.vue-table {
  width: 100%;
  table-layout: auto;

  tr {
    cursor: default;
  }

  td {
    vertical-align: middle;
    padding-top: 0.3rem;
    padding-bottom: 0.3rem;
  }

}

.subject-col {
  width: 18%;
}

.relationship-col {
  width: 24%;
  word-break: break-word;
}

.related-col {
  width: auto;
  overflow: hidden;
  text-overflow: ellipsis;
}

.inverted-col {
  width: 1%;
  white-space: nowrap;
}

.actions-col {
  width: 1%;
  white-space: nowrap;
}

.subject-pill {
  max-width: 100%;
  cursor: default;
  margin: 0;
}

.subject-pill:hover,
.subject-pill:focus,
.subject-pill:active {
  box-shadow: none;
  filter: none;
  transform: none;
  opacity: 1;
}

.subject-name,
.subject-uri-label,
.subject-uri {
  display: inline-block;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.related-col :deep(.otu_tag),
.related-col :deep(.taxon_name),
.related-col :deep(.taxon_name_tag_valid),
.related-col :deep(.taxon_name_tag),
.related-col :deep(.otu_tag_taxon_name) {
  max-width: 100%;
}

.related-col :deep(.otu_tag) {
  display: inline-block;
  overflow: hidden;
}

.related-col :deep(.otu_tag_taxon_name) {
  display: inline-block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.uri-pill {
  background-color: var(--anatomical-part-uri-pill-bg);
  border-color: var(--anatomical-part-uri-pill-border);
  color: var(--anatomical-part-uri-pill-text);
}

.list-complete-item {
  justify-content: space-between;
  transition: all 0.5s, opacity 0.2s;
}

.list-complete-enter-active,
.list-complete-leave-active {
  opacity: 0;
  font-size: 0px;
  border: none;
}
</style>
