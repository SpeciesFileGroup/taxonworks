<template>
  <VModal>
    <template #header>
      <h3>Visualize</h3>
    </template>
    <template #body>
      <div class="flex-separate">
        <div class="full_width">
          <h4 class="capitalize separate-bottom">Time</h4>
          <ul class="no_bullets">
            <li
              class="separate-right"
              v-for="(item, key) in preferences.filterSections.and.time"
              :key="key"
            >
              <label>
                <input
                  v-model="item.value"
                  type="checkbox"
                />
                {{ item.label }}
              </label>
            </li>
          </ul>
          <h4 class="capitalize separate-bottom">Year</h4>
          <YearPicker
            v-model.number="preferences.filterSections.and.year[0].value"
            :years="nomenclature.sources.year_metadata"
          />
        </div>
        <div class="full_width">
          <h4 class="capitalize separate-bottom">Filter</h4>
          <ul class="no_bullets">
            <li
              class="separate-right"
              v-for="(item, key) in preferences.filterSections.and.current"
              :key="key"
            >
              <label>
                <input
                  v-model="item.value"
                  type="checkbox"
                />
                {{ item.label }}
              </label>
            </li>
          </ul>
          <template v-for="section in preferences.filterSections.or">
            <ul class="no_bullets">
              <li
                v-for="(item, key) in section"
                :key="key"
                class="separate-right"
              >
                <label>
                  <input
                    v-model="item.value"
                    type="checkbox"
                  />
                  {{ item.label }}
                </label>
              </li>
            </ul>
          </template>
        </div>
        <div class="full_width">
          <h4 class="capitalize separate-bottom">Show</h4>
          <ul class="no_bullets">
            <li
              class="separate-right"
              v-for="(item, key) in preferences.filterSections.show"
              :key="key"
            >
              <label>
                <input
                  v-model="item.value"
                  type="checkbox"
                />
                {{ item.label }}
              </label>
            </li>
          </ul>
          <h4 class="capitalize separate-bottom">Topic</h4>
          <ul class="no_bullets">
            <li
              v-for="(item, key) in preferences.filterSections.topic"
              :key="key"
            >
              <label>
                <input
                  v-model="item.value"
                  type="checkbox"
                />
                {{ item.label }}
              </label>
            </li>
            <li>
              <label>
                <input
                  v-model="showReferencesTopic"
                  type="checkbox"
                />
                On references
              </label>
            </li>
          </ul>
        </div>
        <div>
          <div class="separate-bottom"></div>
          <ul class="no_bullets topic-section">
            <li
              v-for="(topic, key) in nomenclature.topics.list"
              :key="key"
            >
              <label>
                <input
                  type="checkbox"
                  :value="key"
                  v-model="topicsSelected"
                />
                {{ topic.name }}
              </label>
            </li>
          </ul>
        </div>
      </div>
    </template>
  </VModal>
</template>

<script setup>
import VModal from '@/components/ui/Modal.vue'
import YearPicker from './PanelTimelineYearPicker.vue'

const topcsSelected = defineModel('topic', {
  type: Array,
  default: () => []
})

const preferences = defineModel('preferences', {
  type: Object,
  required: true
})

const props = defineProps({
  nomenclature: {
    type: Object,
    required: true
  }
})
</script>
