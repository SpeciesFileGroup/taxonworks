<template>
  <section-panel
    :status="status"
    :title="title"
    :spinner="isLoading"
  >
    <ul>
      <template
        v-for="(item, index) in collectingEvents"
        :key="item.id"
      >
        <li v-if="index < MAX_LIST || showAll">
          <a
            :href="`/collecting_events/${item.id}`"
            v-html="item.object_tag"
          />
        </li>
      </template>
    </ul>
    <template v-if="collectingEvents.length > MAX_LIST">
      <a
        v-if="!showAll"
        class="cursor-pointer"
        @click="showAll = true"
        >Show all
      </a>
      <a
        v-else
        class="cursor-pointer"
        @click="showAll = false"
        >Show less
      </a>
    </template>
  </section-panel>
</template>

<script setup>
import SectionPanel from '../shared/sectionPanel'
import { GetterNames } from '../../store/getters/getters'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'

const MAX_LIST = 10

defineProps({
  status: {
    type: String,
    default: 'unknown'
  },
  title: {
    type: String,
    default: undefined
  }
})

const store = useStore()

const showAll = ref(false)

const isLoading = computed(() => {
  const loadState = store.getters[GetterNames.GetLoadState]

  return loadState.collectingEvents
})

const collectingEvents = computed(
  () => store.getters[GetterNames.GetCollectingEvents]
)
</script>
