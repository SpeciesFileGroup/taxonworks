<template>
  <div>
    <h2>Recently created</h2>
    <VSpinner v-if="isLoading" />
    <table class="full_width">
      <thead>
        <tr>
          <th>Catalog number</th>
          <th>Total</th>
          <th>Family</th>
          <th>Genus</th>
          <th>Scientific name</th>
          <th>Identifier</th>
          <th>Level 1</th>
          <th>Level 2</th>
          <th>Level 3</th>
          <th>Verbatim locality</th>
          <th>Container</th>
          <th>Updated by</th>
          <th>Updated at</th>
          <th />
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(item, index) in store.recentList"
          :key="item.id"
          class="contextMenuCells"
          :class="{ 'even': (index % 2 == 0) }"
        >
          <td>{{ item.dwc_attributes.catalogNumber }}</td>
          <td>{{ item.dwc_attributes.individualCount }}</td>
          <td>{{ item.dwc_attributes.family }}</td>
          <td>{{ item.dwc_attributes.genus }}</td>
          <td>{{ item.dwc_attributes.scientificName }}</td>
          <td
            v-if="item.identifier_from_container"
            v-html="item.object_tag"
          />
          <td v-else>
            {{ item.dwc_attributes.catalogNumber }}
          </td>
          <td>{{ item.dwc_attributes.country }}</td>
          <td>{{ item.dwc_attributes.stateProvince }}</td>
          <td>{{ item.dwc_attributes.county }}</td>
          <td>{{ item.dwc_attributes.verbatimLocality }}</td>
          <td v-html="item.container" />
          <td>{{ item.updater }}</td>
          <td>{{ item.updated_at }}</td>
          <td>
            <div class="horizontal-right-content">
              <TagButtom
                class="circle-button"
                :global-id="item.global_id"
              />
              <RadialObject :global-id="item.global_id" />
              <RadialAnnotator :global-id="item.global_id" />
              <RadialNavigation :global-id="item.global_id" />
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useStore } from '../store/useStore'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'
import TagButtom from 'components/defaultTag.vue'
import VSpinner from 'components/spinner'

const store = useStore()
const isLoading = ref(false)

</script>
