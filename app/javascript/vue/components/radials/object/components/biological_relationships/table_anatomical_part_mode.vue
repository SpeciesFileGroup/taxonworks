<template>
  <div>
    <table class="vue-table">
      <thead>
        <tr>
          <th class="subject-col">Subject</th>
          <th class="relationship-col">Relationship</th>
          <th class="related-col">Related</th>
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
            <span
              v-if="item.subject_anatomical_part?.name"
              class="button normal-input tag_button button-data subject-pill name-pill"
              :title="item.subject_anatomical_part.name"
            >
              <span class="subject-name">{{ item.subject_anatomical_part.name }}</span>
            </span>
            <span
              v-else
              class="button normal-input tag_button button-data subject-pill uri-pill"
              :title="uriPillTitle(item)"
            >
              <span class="subject-uri-label">{{ item.subject_anatomical_part?.uri_label }}</span>
            </span>
          </td>
          <td
            class="relationship-col"
            v-html="item.biological_relationship.object_tag"
          />
          <td
            class="related-col"
            v-html="item.object?.object_tag"
          />
          <td class="actions-col">
            <div class="horizontal-right-content gap-xsmall">
              <citation-count
                :object="item"
                :values="item.citations"
                target="biological_associations"
              />
              <RadialAnnotator :global-id="item.global_id" />
              <RadialObject :global-id="item.global_id" />
              <VBtn
                circle
                color="primary"
                @click="emit('edit', Object.assign({}, item))"
              >
                <VIcon
                  name="pencil"
                  x-small
                />
              </VBtn>

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
import CitationCount from '../shared/citationsCount.vue'

defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['delete', 'edit'])

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
  table-layout: fixed;

  tr {
    cursor: default;
  }

  td {
    vertical-align: top;
    padding-top: 0.3rem;
    padding-bottom: 0.3rem;
  }

}

.subject-col {
  width: 30%;
}

.relationship-col {
  width: 20%;
  word-break: break-word;
}

.related-col {
  width: 30%;
}

.actions-col {
  width: 20%;
}

.subject-pill {
  display: inline-flex;
  flex-direction: column;
  gap: 0.1rem;
  line-height: 1.15;
  max-width: 100%;
  padding-top: 0.2rem;
  padding-bottom: 0.2rem;
  cursor: default;
}

.subject-pill:hover,
.subject-pill:focus,
.subject-pill:active {
  box-shadow: none;
  filter: none;
  transform: none;
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

.subject-uri-label {
  font-weight: 600;
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
