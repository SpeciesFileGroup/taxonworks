<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true">Recent</button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Recent collection objects</h3>
      <div slot="body">
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
              <template>
                <td 
                  v-if="item.identifier_from_container"
                  v-html="item.object_tag"/>
                <td v-else>{{ item.dwc_attributes.catalogNumber}}</td>
              </template>
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
      </div>
    </modal-component>
  </div>
</template>

<script>

  import ModalComponent from 'components/modal'
  import SpinnerComponent from 'components/spinner'
  import { GetRecentCollectionObjects } from '../../request/resources.js'

  export default {
    components: {
      ModalComponent,
      SpinnerComponent
    },
    data() {
      return {
        showModal: false,
        list: [],
        isLoading: false
      }
    },
    watch: {
      showModal (newVal) {
        if(newVal) {
          this.isLoading = true
          GetRecentCollectionObjects().then(response => {
            this.list = response.body
            this.isLoading = false
          })
        }
      }
    },
    methods: {
      sendCO(item) {
        this.showModal = false
        this.$emit('selected', item)
      }
    }
  }
</script>

