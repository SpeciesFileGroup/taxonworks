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
              <lock-component
                v-model="settings.locked.biologicalAssociations"
              />
            </div>
          </th>
        </tr>
      </thead>
      <transition-group
        name="list-complete"
        tag="tbody"
      >
        <template
          v-for="(item, index) in renderList"
          :key="item.id"
        >
          <tr class="list-complete-item">
            <td v-html="item.relationship" />
            <td v-html="item.object" />
            <td v-html="item.citation" />
            <td>
              <div class="middle horizontal-right-content gap-small">
                <RadialAnnotator
                  v-if="item.globalId"
                  :global-id="item.globalId"
                />
                <span
                  class="circle-button btn-delete"
                  :class="{ 'button-default': !item.id }"
                  @click="deleteItem(index)"
                >
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

<script setup>
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import LockComponent from '@/components/ui/VLock/index.vue'
import { GetterNames } from '../../store/getters/getters'
import { MutationNames } from '../../store/mutations/mutations'
import { computed } from 'vue'
import { useStore } from 'vuex'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  }
})

const renderList = computed(() =>
  props.list.map((item) => ({
    id: item.id,
    globalId: item.global_id,
    relationship: getRelationshipString(item),
    object: item.object.object_tag,
    citation: getCitationString(item)
  }))
)

const store = useStore()

const emit = defineEmits(['delete'])

const settings = computed({
  get() {
    return store.getters[GetterNames.GetSettings]
  },
  set(value) {
    store.commit(MutationNames.SetSettings, value)
  }
})

function deleteItem(item) {
  if (item.id) {
    if (
      window.confirm(
        "You're trying to delete this record. Are you sure want to proceed?"
      )
    ) {
      emit('delete', item)
    }
  } else {
    emit('delete', item)
  }
}

function getRelationshipString(item) {
  return (
    item.biological_relationship.name ||
    item.biological_relationship.object_label
  )
}

function getCitationString(object) {
  const citation = object?.origin_citation || object?.origin_citation_attributes

  if (citation?.source) {
    const authorString = citation.source?.cached_author_string

    return [authorString, citation.source.year].filter(Boolean).join(', ')
  }

  return ''
}
</script>
<style lang="scss" scoped>
:deep(.otu_tag_taxon_name) {
  white-space: normal !important;
}
</style>
