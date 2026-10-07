<template>
  <PanelLayout
    :status="status"
    :spinner="isLoading"
    :empty="!assertedEnvironments.length"
    :name="title"
    :title="`${title} ${pagination ? '(' + pagination.total + ')' : ''}`"
  >
    <template v-if="assertedEnvironments.length">
      <VPagination
        v-if="pagination"
        class="margin-small-top margin-small-bottom"
        :pagination="pagination"
        @next-page="(e) => loadAssertedEnvironments(e.page)"
      />
      <TableDisplay
        :list="assertedEnvironments"
        :header="['Environment', 'Object', '']"
        :destroy="false"
        :attributes="[
          'uri_label',
          ['asserted_environment_object', 'object_tag']
        ]"
      />
    </template>
    <div v-else>No asserted environments available</div>
  </PanelLayout>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { AssertedEnvironment } from '@/routes/endpoints'
import { getPagination } from '@/helpers'
import { OTU } from '@/constants'
import PanelLayout from '../PanelLayout.vue'
import TableDisplay from '@/components/table_list'
import VPagination from '@/components/pagination.vue'

const props = defineProps({
  otu: {
    type: Object,
    required: true
  },

  otus: {
    type: Array,
    required: true
  },

  status: {
    type: String,
    default: 'unknown'
  },

  title: {
    type: String,
    default: 'Asserted environments'
  }
})

const PER_PAGE = 50

const assertedEnvironments = ref([])
const isLoading = ref(false)
const pagination = ref()

const otuIds = computed(() => props.otus.map((o) => o.id))

async function loadAssertedEnvironments(page = 1) {
  isLoading.value = true

  try {
    const response = await AssertedEnvironment.filter({
      asserted_environment_object_id: otuIds.value,
      asserted_environment_object_type: OTU,
      page,
      per: PER_PAGE
    })

    pagination.value = getPagination(response)
    assertedEnvironments.value = response.body
  } catch {
  } finally {
    isLoading.value = false
  }
}

watch(
  () => props.otus,
  (newVal) => {
    if (newVal.length > 0) {
      loadAssertedEnvironments()
    }
  },
  { immediate: true }
)
</script>
