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
          >
            <div
              class="related-content"
              v-html="item.object?.object_tag"
            />
          </td>
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
                color="destroy"
                @click="deleteItem(item)"
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
  width: max-content;
  min-width: 1400px;
  table-layout: auto;

  tr {
    cursor: default;
  }

  td {
    vertical-align: middle;
    padding-top: 0.1rem;
    padding-bottom: 0.1rem;
  }

}

.related-content {
  display: inline-flex;
  align-items: center;
  gap: 0.15rem 0.35rem;
  white-space: nowrap;
  line-height: 1.3;
}

.related-col :deep(br) {
  display: none;
}


.inverted-col {
  white-space: nowrap;
}

.actions-col {
  white-space: nowrap;
}

.subject-pill {
  display: inline-flex;
  align-items: center;
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

.related-col :deep(.otu_tag) {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  vertical-align: middle;
}

.related-col :deep(.otu_tag_taxon_name) {
  line-height: 1.4;
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
