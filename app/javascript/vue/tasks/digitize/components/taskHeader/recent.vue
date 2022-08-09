<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true">Recent</button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <template #header>
        <h3>Recent collection objects</h3>
      </template>
      <template #body>
        <spinner-component v-if="isLoading"/>
        <table class="full_width">
          <thead>
            <tr>
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
              v-for="(item, index) in list"
              :key="item.id"
              class="contextMenuCells"
              :class="{ 'even': (index % 2 == 0) }"
              @click="sendCO(item)">
              <td>{{ item.dwc_attributes.individualCount }}</td>
              <td>{{ item.dwc_attributes.family }}</td>
              <td>{{ item.dwc_attributes.genus }}</td>
              <td>{{ item.dwc_attributes.scientificName }}</td>
              <td
                v-if="item.identifier_from_container"
                v-html="item.object_tag"/>
              <td v-else>
                {{ item.dwc_attributes.catalogNumber }}
              </td>
              <td>{{ item.biocuration }}</td>
              <td>{{ item.dwc_attributes.country }}</td>
              <td>{{ item.dwc_attributes.stateProvince }}</td>
              <td>{{ item.dwc_attributes.county }}</td>
              <td>{{ item.dwc_attributes.verbatimLocality }}</td>
              <td>{{ item.dwc_attributes.eventDate }}</td>
              <td v-html="item.container"/>
              <td>{{ item.updated_at }}</td>
            </tr>
          </tbody>
        </table>
      </template>
    </modal-component>
  </div>
</template>

<script>

import ModalComponent from 'components/ui/Modal'
import SpinnerComponent from 'components/spinner'
import { CollectionObject } from 'routes/endpoints'

export default {
  components: {
    ModalComponent,
    SpinnerComponent
  },

  emits: ['selected'],

  data () {
    return {
      showModal: false,
      list: [],
      isLoading: false
    }
  },

  watch: {
    showModal (newVal) {
      if (newVal) {
        this.isLoading = true
        CollectionObject.reportDwc({ per: 10 }).then(response => {
          this.list = response.body
          this.isLoading = false
        })
      }
    }
  },

  methods: {
    sendCO (item) {
      this.showModal = false
      this.$emit('selected', item)
    }
  }
}
</script>
