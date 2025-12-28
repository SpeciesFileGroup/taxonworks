<template>
  <div class="panel content">
    <h2>Download Darwin Core Archive</h2>

    <div class="margin-medium-bottom">
      <h3>Occurrence Downloads</h3>
      <i>Includes only records stored as DwC occurrences.</i>
    </div>
    <div class="field label-above margin-medium-top">
      <DwcDownload
        :params="{ per: downloadCount }"
        v-slot="{ action }"
        @create="actions.addDownloadRecord"
      >
        <VBtn
          class="capitalize"
          color="create"
          :total="downloadCount"
          medium
          :disabled="!downloadCount"
          @click="action"
        >
          All ({{ downloadCount }})
        </VBtn>
      </DwcDownload>
    </div>
    <div class="field label-above">
      <label>Past</label>
      <div class="horizontal-left-content gap-small">
        <DwcDownload
          v-for="(days, key) in DATE_BUTTONS"
          :key="key"
          :params="makeParameters(days)"
          v-slot="{ action }"
          @create="actions.addDownloadRecord"
        >
          <VBtn
            class="capitalize"
            color="create"
            medium
            :disabled="!getTotal(key)"
            @click="action"
          >
            {{ key }} ({{ getTotal(key) }})
          </VBtn>
        </DwcDownload>
      </div>
    </div>
    <filter-link>
      Create DwC Archive by filtered collection object result
    </filter-link>

    <hr class="divisor full_width margin-large-top" />

    <div class="margin-large-top">
      <h3>Checklist Downloads</h3>
      Taxonomic checklists with optional extensions. <i>Includes only records stored as DwC occurrences.</i>
      <div class="margin-medium-top">
        <a :href="filterOtusLink">
          Create DwC Checklist by filtered OTU result
        </a>
      </div>
    </div>
  </div>
</template>
<script setup>
import { getPastDateByDays } from '@/helpers/dates.js'
import { inject, computed } from 'vue'
import { RouteNames } from '@/routes/routes.js'
import VBtn from '@/components/ui/VBtn/index.vue'
import DwcDownload from '@/tasks/collection_objects/filter/components/dwcDownload.vue'
import FilterLink from '../FilterLink.vue'

const DATE_BUTTONS = {
  day: 1,
  week: 7,
  month: 30,
  year: 365
}

const actions = inject('actions')
const state = inject('state')
const downloadCount = computed(() => state?.metadata?.index?.record_total)

function getTotal(date) {
  return state?.metadata?.index.freshness[`one_${date}`]
}

function makeParameters(days) {
  return {
    user_date_start: getPastDateByDays(Number(days)),
    user_date_end: getPastDateByDays(0),
    dwc_indexed: true
  }
}

const filterOtusLink = computed(() => {
  const params = new URL(window.location.href).searchParams.toString()
  return `${RouteNames.FilterOtus}${params ? '?' + params : ''}`
})
</script>
