<template>
  <div class="panel content">
    <h2>Existing data</h2>
    <div style="overflow-x: scroll">
      <table>
        <thead>
          <tr>
            <th>
              <input
                type="checkbox"
                v-model="toggleCheckbox"
              />
            </th>
            <th>Total</th>
            <th>Family</th>
            <th>Genus</th>
            <th>Scientific name</th>
            <th>Identifier</th>
            <th>Biocuration attributes</th>
            <th>Level 1</th>
            <th>Level 2</th>
            <th>Level 3</th>
            <th>Verbatim locality</th>
            <th>Date start</th>
            <th>Container</th>
            <th>Update at</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(item, index) in store.collectionObjects"
            :key="item.id"
            class="contextMenuCells"
            :class="{ even: index % 2 == 0 }"
          >
            <td>
              <input
                type="checkbox"
                v-model="store.selectedId"
                :value="item.id"
              />
            </td>
            <td>
              <div class="horizontal-left-content middle gap-small">
                <RadialAnnotator :global-id="item.global_id" />
                <RadialObject
                  button-class="btn-co-radial"
                  :global-id="item.global_id"
                />
                <RadialNavigation :global-id="item.global_id" />
              </div>
            </td>
            <td>{{ item.dwc_attributes.individualCount }}</td>
            <td>{{ item.dwc_attributes.family }}</td>
            <td>{{ item.dwc_attributes.genus }}</td>
            <td>{{ item.dwc_attributes.scientificName }}</td>
            <td
              v-if="item.identifier_from_container"
              v-html="item.object_tag"
            />
            <td v-else>{{ item.dwc_attributes.catalogNumber }}</td>
            <td>{{ item.biocuration }}</td>
            <td>{{ item.dwc_attributes.country }}</td>
            <td>{{ item.dwc_attributes.stateProvince }}</td>
            <td>{{ item.dwc_attributes.county }}</td>
            <td>{{ item.dwc_attributes.verbatimLocality }}</td>
            <td>{{ item.dwc_attributes.eventDate }}</td>
            <td v-html="item.container" />
            <td>{{ item.updated_at }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialNavigation from '@/components/radials/navigation/radial'
import RadialObject from '@/components/radials/object/radial'
import useStore from '../store/store.js'

const store = useStore()
const toggleCheckbox = computed({
  get: () => store.collectionObjects.length === store.selectedId.length,
  set: (value) => {
    store.selectedId = value
      ? store.collectionObjects.map((item) => item.id)
      : []
  }
})
</script>
