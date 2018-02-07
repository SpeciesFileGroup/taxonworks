<template>
  <div>
    <span 
      class="circle-button btn-hexagon-w button-default"
      :class="{ 'button-submit': !list.length }"
      @click="openApp">Otu
    </span>
    <modal
      @close="modalOpen = false"
      v-if="modalOpen">
      <div slot="header">
        <h3>
          <span v-if="list.length">
            <span v-html="taxonName"/> is linked to {{ list.length }} Otus, go to:
          </span>
          <span v-else>
            <span v-html="taxonName"/> is not linked to an OTU
          </span>
        </h3>
      </div>
      <div slot="body">
        <ul class="no_bullets">
          <li
            v-for="item in list"
            :key="item.id">
            <a
              :href="`/tasks/otus/browse/${item.id}`"
              v-html="item.object_tag"/>
          </li>
        </ul>
        <spinner
          v-if="creatingOtu"
          legend="Creating Otu..."/>
      </div>
    </modal>
  </div>
</template>

<script>

  import Modal from '../modal.vue'
  import Spinner from '../spinner.vue'
  import { GetOtus, CreateOtu } from './request/resources'

  export default {
    components: {
      Modal,
      Spinner
    },
    props: {
      taxonId: {
        type: [String, Number],
        required: true
      },
      taxonName: {
        type: String,
        default: ''
      }
    },
    computed: {
      emptyList() {
        return !this.list.length
      }
    },
    data() {
      return {
        modalOpen: false,
        creatingOtu: false,
        list: []
      }
    },
    mounted() {
      this.loadOtus(this.taxonId)
    },
    methods: {
      openApp() {
        this.modalOpen = true
        if(this.emptyList) {
          this.createOtu(this.taxonId);
        }
      },
      loadOtus(id) {
        GetOtus(id).then(response => {
          this.list = response
        })
      },
      createOtu(id) {
        this.creatingOtu = true
        CreateOtu(id).then(response => {
          window.location.href = `/tasks/otus/browse/${response.id}`
        }) 
      }
    }
  }
</script>