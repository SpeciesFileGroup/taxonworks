<template>
  <div>
    <VSpinner
      v-if="loading"
      legend="Loading keys..."
      :logo-size="{ width: '100px', height: '100px' }"
    />
    <h3 class="title-section">Keys</h3>
    <div class="keys_list">
      <table
        v-if="keys.length"
        class="vue-table"
      >
        <thead>
          <tr>
            <th
              @click="() => sortTable('text')"
              class="table_name_col"
            >
              Name
            </th>
            <th
              @click="() => sortTable('couplets_count')"
              class="width_shrink"
            >
              # Couplets
            </th>
            <th @click="() => sortTable('key_updated_at')">
              Last Modified
            </th>
            <th @click="() => sortTable('key_updated_by')">
              Last Modified By
            </th>
            <th class="width_shrink"/> <!-- radials -->
            <th
              @click="() => sortTable('is_public')"
              class="width_shrink"
            >
              Is Public
            </th>
          </tr>
        </thead>
        <tbody>
          <template
            v-for="(key, index) in keys"
            :key="key.id"
          >
            <tr
              class="meta_row"
              :class="{ even: (index % 2 == 0)}"
            >
              <td>
                <b>
                  <a
                    :href="RouteNames.ShowLead + '?lead_id=' + key.id"
                    target="_blank"
                  >
                    {{ key.text }}
                  </a>
                </b>
              </td>

              <td>{{ key.couplets_count }}</td>

              <td>{{ key.key_updated_at_in_words }}</td>

              <td>{{ key.key_updated_by }}</td>

              <td>
                <div class="horizontal-right-content gap-small">
                  <RadialAnnotator :global-id="key.global_id" />
                  <RadialNavigator :global-id="key.global_id" />
                </div>
              </td>

              <td>
                <input
                  type="checkbox"
                  :checked="key.is_public"
                  @click="() => changeIsPublicState(key)"
                />
              </td>
            </tr>

            <tr :class="{ even: (index % 2 == 0)}">
              <td
                colspan="2"
                class="extension_data"
              >
                <KeyOtus
                  :key-prop="key"
                  @load-otus-for-key="() => loadOtusForKey(key)"
                />
              </td>
              <td
                colspan="4"
                class="extension_data"
              >
                <KeyCitations :citations="key.citations" />
              </td>
            </tr>
          </template>
        </tbody>
      </table>

      <div v-else-if="!loading">
        No keys currently available. Use the
        <a
          :href="RouteNames.NewLead"
          data-turbolinks="false"
        >
          New key
        </a>
        task to create one.
      </div>
    </div>
  </div>
</template>

<script setup>
import { addToArray } from '@/helpers/arrays'
import { Citation, Lead } from '@/routes/endpoints'
import { LEAD } from '@/constants/index.js'
import { onBeforeMount, ref } from 'vue'
import { RouteNames } from '@/routes/routes'
import { sortArray } from '@/helpers'
import KeyCitations from './KeyCitations.vue'
import KeyOtus from './KeyOtus.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const keys = ref([])
const loading = ref(true)
const ascending = ref(false)

onBeforeMount(async () => {
  const loadKeys = Lead.where({ load_root_otus: true })
    .then(({ body }) => {
      keys.value = body
    })

  const loadCitations = Citation.where({
    citation_object_type: LEAD,
    extend: ['source']
  })

  Promise.allSettled([loadKeys, loadCitations])
    .then(([_, { value }]) => {
      addCitationsToKeysList(value.body)
    })
    .catch(() => {})
    .finally(() => {
      loading.value = false
    })
})

function addCitationsToKeysList(citations) {
  citations.forEach((citation) => {
    const i = keys.value.findIndex(
      (key) => (key.id == citation.citation_object_id)
    )
    if (i != -1) {
      if (keys.value[i].citations) {
        keys.value[i].citations.push(citation)
      } else {
        keys.value[i].citations = [ citation ]
      }
    }
  })
}

function sortTable(sortProperty) {
  keys.value = sortArray(keys.value, sortProperty, ascending.value)
  ascending.value = !ascending.value
}

function changeIsPublicState(key) {
  const payload = {
    lead: {
      is_public: !key.is_public
    },
    extend: ['updater', 'updated_at_in_words']
  }

  Lead.update(key.id, payload)
    .then(({ body }) => {
      const updatedKey = {
        ...body.lead,
        otu: key.otu,
        otus_count: key.otus_count,
        couplets_count: key.couplets_count,
        citations: key.citations,
        child_otus: key.child_otus,
        key_updated_at: body.lead.updated_at,
        key_updated_at_in_words: body.lead.updated_at_in_words,
        key_updated_by: body.lead.updated_by,
        key_updated_by_id: body.lead.updated_by_id
      }

      addToArray(keys.value, updatedKey)
    })
    .catch(() => {})
}

function loadOtusForKey(key) {
  Lead.otus(key.id)
    .then(({ body }) => {
      let otus = body
      if (key.otu) {
        // Remove the root otu, which is already displayed.
        const i = otus.findIndex((otu) => (otu.id == key.otu_id))
        if (i != -1) {
          otus.splice(i, 1)
        }
      }

      otus.sort((a, b) => {
        if (a.object_label == b.object_label) {
          return a.id < b.id ? -1 : 1
        }
        return a.object_label < b.object_label ? -1 : 1
      })

      key.child_otus = otus
      addToArray(keys.value, key)
    })
    .catch(() => {
      // Add child_otus or the loading spinner will never disappear.
      key.child_otus = []
      addToArray(keys.value, key)
    })
}
</script>

<style lang="scss" scoped>
.keys_list {
  margin-right: 1em;
  margin-bottom: 2em;
}
.width_shrink {
  width: 1%;
}
.meta_row:not(:first-child) {
  border-top: 2px solid var(--color-primary);
}
.extension_data {
  border-top: 4px dotted #eee;
  padding-top: .5em;
  padding-bottom: .5em;
}
.table_name_col {
  width: 45%;
}
</style>
