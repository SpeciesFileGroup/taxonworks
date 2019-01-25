<template>
  <div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="showModal = true">Recent</button>
    <modal-component
      v-if="showModal"
      @close="showModal = false">
      <h3 slot="header">Recent collection objets</h3>
      <div slot="body">
        <ul class="no_bullets">
          <li 
            v-for="item in list"
            :key="item.id">
            <label
              @click="sendCO(item)">
              <input
                type="radio"
                name="recent-co">
              {{ item.object_tag }}
            </label>
          </li>
        </ul>
      </div>
    </modal-component>
  </div>
</template>

<script>

  import ModalComponent from 'components/modal'
  import { GetRecentCollectionObjects } from '../../request/resources.js'

  export default {
    components: {
      ModalComponent
    },
    data() {
      return {
        showModal: false,
        list: []
      }
    },
    mounted() {
      GetRecentCollectionObjects().then(response => {
        this.list = response
      })
    },
    methods: {
      sendCO(item) {
        this.showModal = false
        this.$emit('selected', item)
      }
    }
  }
</script>
