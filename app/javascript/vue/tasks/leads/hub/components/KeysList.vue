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
              @click="() => sortTable('couplet_count')"
              class="narrow_col"
            >
              # Couplets
            </th>
            <th
              @click="() => sortTable('is_public')"
              class="narrow_col"
            >
              Is Public
            </th>
            <th @click="() => sortTable('updated_at')">
              Last Modified
            </th>
            <th @click="() => sortTable('updated_by')">
              Last Modified By
            </th>
            <th /> <!-- radials -->
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

              <td>{{ key.couplet_count }}</td>

              <td>
                <input
                  type="checkbox"
                  :checked="key.is_public"
                  @click="() => changeIsPublicState(key)"
                />
              </td>

              <td>{{ key.updated_at_in_words }}</td>

              <td>{{ key.updated_by }}</td>

              <td class="width-shrink">
                <div class="horizontal-right-content gap-small">
                  <RadialAnnotator :global-id="key.global_id" />
                  <RadialNavigator :global-id="key.global_id" />
                </div>
              </td>
            </tr>

            <tr :class="{ even: (index % 2 == 0)}">
              <td
                colspan="3"
                class="extension_data"
              >
                <KeyOtus
                  :key-prop="key"
                  @load-otus-for-key="() => loadOtusForKey(key)"
                />
              </td>
              <td
                colspan="3"
                class="extension_data"
              >
                <KeyCitations :citations="key.citations" />
              </td>
            </tr>
          </template>
        </tbody>
      </table>

      <div v-else-if="!loading">
        No key currently available. Use the
        <a
          :href="RouteNames.NewLead"
          data-turbolinks="false"
        >
          New dichotomous key
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
  const loadKeys = Lead.where({
    extend: ['couplet_count', 'updater', 'updated_at_in_words', 'otu']
   })
    .then(({ body }) => {
      keys.value = body
    })
    .finally(() => {
      loading.value = false
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

  Lead.update_meta(key.id, payload)
    .then(({ body }) => {
      const updatedKey = {
        ...body.lead,
        otu: key.otu,
        otus_count: key.otus_count,
        couplet_count: key.couplet_count,
        citations: key.citations,
        child_otus: key.child_otus
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
        const i = otus.find((otu) => (otu.id == key.otu_id))
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
.width-shrink {
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
  width: 40%;
}
.narrow_col {
  width: 4em;
}
</style>
