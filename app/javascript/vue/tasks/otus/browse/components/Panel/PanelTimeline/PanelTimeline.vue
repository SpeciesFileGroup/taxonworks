<template>
  <PanelLayout
    :status="status"
    :title="title"
    :spinner="isLoading"
    menu
    @menu="() => (isModalVisible = true)"
  >
    <div class="switch-radio separate-top separate-bottom">
      <template
        v-for="(item, index) in filterTabs"
        :key="index"
      >
        <input
          v-model="tabSelected"
          :id="`switch-filter-nomenclature-${index}`"
          name="switch-filter-nomenclature-options"
          type="radio"
          class="normal-input button-active"
          :value="item"
        />
        <label :for="`switch-filter-nomenclature-${index}`">{{
          item.label
        }}</label>
      </template>
    </div>
    <div
      v-if="nomenclature"
      :class="
        Object.assign(
          {},
          ...preferences.filterSections.show
            .concat(preferences.filterSections.topic)
            .map((item) => ({ [item.key]: !item.value }))
        )
      "
    >
      <timeline-citations :citations="filteredList" />
      <h3>References</h3>
      <ul
        v-if="nomenclature"
        class="no_bullets"
      >
        <template v-if="selectedReferences.length">
          <template
            v-for="item in references"
            :key="item"
          >
            <li
              v-show="filterSource(nomenclature.sources.list[item])"
              class="horizontal-left-content gap-small"
            >
              <label>
                <input
                  v-model="references"
                  :value="item"
                  class="margin-small-right"
                  type="checkbox"
                />
                <span v-html="nomenclature.sources.list[item].cached" />
              </label>
              <RadialAnnotator :global-id="item" />
              <RadialNavigation :global-id="item" />
            </li>
          </template>
        </template>
        <template v-else>
          <template
            v-for="(item, key) in nomenclature.sources.list"
            :key="key"
          >
            <li
              v-show="filterSource(item)"
              class="horizontal-left-content gap-small"
            >
              <label>
                <input
                  v-model="references"
                  :value="key"
                  class="margin-small-right"
                  type="checkbox"
                />
                <span v-html="item.cached" />
              </label>
              <template v-if="showReferencesTopic">
                <span
                  v-for="(topic, index) in getSourceTopics(item).map(
                    (key) => nomenclature.topics.list[key]
                  )"
                  class="pill topic references_topics"
                  :key="index"
                  :style="{ 'background-color': topic.css_color }"
                  v-html="topic.name"
                />
              </template>
              <RadialAnnotator :global-id="key" />
              <RadialNavigation :global-id="key" />
            </li>
          </template>
        </template>
      </ul>
    </div>
    <soft-validation-modal />
    <PanelTimelineSettings
      v-if="isModalVisible"
      :nomenclature="nomenclature"
      :preferences="preferences"
      v-model:topic="topicsSelected"
      @close="() => (isModalVisible = false)"
    />
  </PanelLayout>
</template>

<script setup>
import { Otu } from '@/routes/endpoints'
import { useUserPreferences } from '@/composables'
import { computed, ref, watch } from 'vue'
import PanelLayout from '../PanelLayout.vue'
//import SoftValidationModal from '../softValidationModal'
import TimelineCitations from './PanelTimelineCitations.vue'
import PanelTimelineSettings from './PanelTimelineSettings.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  }
})

const KEY_STORAGE = 'task::BrowseOtus'

const userPref = useUserPreferences()

const preferences = computed(
  () => userPref.preferences.value.layout?.[KEY_STORAGE]
)

const filterTabs = [
  {
    label: 'All',
    key: '',
    value: '',
    equal: true
  },
  {
    label: 'Nomenclature',
    key: 'history-origin',
    value: 'otu',
    equal: false
  },
  {
    label: 'Protonym',
    key: 'history-origin',
    value: 'protonym',
    equal: true
  },
  {
    label: 'OTU (biology)',
    key: 'history-origin',
    value: 'otu',
    equal: true
  }
]

const selectedReferences = computed(() =>
  references.value.map((item) => nomenclature.value.sources.list[item])
)

const itemsList = computed(() =>
  references.value.length
    ? nomenclature.value.items.filter((item) =>
        selectedReferences.value.find((ref) =>
          ref.objects.includes(item.data_attributes['history-object-id'])
        )
      )
    : nomenclature.value.items
)
const filteredList = computed(() =>
  Array.isArray(itemsList.value) ? itemsList.value.filter(checkFilter) : []
)

const isLoading = ref(false)
const showReferencesTopic = ref(false)
const references = ref([])
const topicsSelected = ref([])
const isModalVisible = ref(false)
const nomenclature = ref()
const tabSelected = ref({
  label: 'All',
  key: '',
  value: ''
})

watch(
  () => props.otu,
  (newVal) => {
    if (newVal) {
      isLoading.value = true

      Otu.timeline(props.otu.id)
        .then(({ body }) => {
          nomenclature.value = body
        })
        .finally(() => {
          isLoading.value = false
        })
    }
  },
  { immediate: true }
)

function checkFilter(item) {
  const { and, or } = preferences.value.filterSections
  const { label, value, equal, key } = tabSelected.value
  const attrs = item.data_attributes

  const matchesTab =
    label === 'All' || (equal ? attrs[key] === value : attrs[key] !== value)

  const matchFilter = (filter) =>
    filter.value === undefined ||
    (filter.equal
      ? attrs[filter.key] === filter.value
      : attrs[filter.key] !== filter.value)

  const matchAndSections = Object.values(and).every((group) => {
    if (group.every((f) => f.value === false)) return true

    return group.every(matchFilter)
  })

  const matchOrSections = Object.values(or).every((group) =>
    group.some(matchFilter)
  )

  const matchTopics =
    !topicsSelected.value.length ||
    item.topics.some((t) => topicsSelected.value.includes(t))

  return matchesTab && matchAndSections && matchOrSections && matchTopics
}

function filterSource(source) {
  const globalIds = source.objects

  return itemsList.value
    .filter(checkFilter)
    .find((item) =>
      globalIds.includes(item.data_attributes['history-object-id'])
    )
}

function getSourceTopics(source) {
  const globalIds = source.objects
  const topics = itemsList.value
    .filter(checkFilter)
    .filter((item) =>
      globalIds.includes(item.data_attributes['history-object-id'])
    )
    .map((item) => item.topics)

  return [...new Set([].concat(...topics))]
}
</script>
<style lang="scss" scoped>
.hidden {
  display: none;
}
:deep(.modal-container) {
  width: 900px;
}
.topic-section {
  overflow-y: scroll;
  max-height: 480px;
}
.references_topics {
  color: black;
}
:deep(.annotation__note) {
  display: inline;
}
:deep(.hide-validations) {
  .soft_validation_anchor {
    display: none !important;
  }
}
:deep(.hide-notes) {
  .history__citation_notes {
    display: none !important;
  }
}
:deep(.hide-topics) {
  .history__citation_topics {
    display: none !important;
  }
}
</style>
