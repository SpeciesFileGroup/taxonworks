<template>
  <div>
    <span 
      class="circle-button button-default"
      :title="redirect ? 'Otu browse' : 'Otu radial'"
      :class="[{ 'button-submit': !list.length }, (redirect ? 'btn-hexagon-empty-w' : 'btn-hexagon-w')]"
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
              href="#"
              @click="processCall(item)"
              v-html="item.object_tag"/>
          </li>
        </ul>
        <spinner
          v-if="creatingOtu"
          legend="Creating Otu..."/>
      </div>
    </modal>
    <radial-annotator
      ref="annotator"
      type="graph"
      :show-bottom="false"
      :global-id="globalId"/>
  </div>
</template>

<script>

  import Modal from '../modal.vue'
  import Spinner from '../spinner.vue'
  import RadialAnnotator from '../annotator/annotator.vue'
  import { GetOtus, CreateOtu } from './request/resources'

  export default {
    components: {
      Modal,
      Spinner,
      RadialAnnotator
    },
    props: {
      taxonId: {
        type: [String, Number],
        required: true
      },
      taxonName: {
        type: String,
        default: ''
      },
      redirect: {
        type: Boolean,
        default: true
      },
    },
    computed: {
      emptyList() {
        return !this.list.length
      }
    },
    data() {
      return {
        globalId: '',
        modalOpen: false,
        creatingOtu: false,
        list: []
      }
    },
    mounted() {
      GetOtus(this.taxonId).then(response => {
        this.list = response
      })
    },
    methods: {
      openApp() {
        if(this.emptyList) {
          this.createOtu(this.taxonId);
        }
        else if(this.list.length === 1) {
          this.processCall(this.list[0])
        }
        else {
          this.modalOpen = true
        }
      },
      openRadial(otu) {
        this.globalId = otu.global_id
        this.$nextTick(()=> {
          this.$refs.annotator.displayAnnotator()
        })
      },
      createOtu(id) {
        this.creatingOtu = true
        CreateOtu(id).then(response => {
          if(this.redirect) {
            this.redirectTo(response.id)
          }
          else {
            this.openRadial(response)
          }
        }) 
      },
      processCall(otu) {
        if(this.redirect) {
          this.redirectTo(otu.id)
        }
        else {
          this.openRadial(otu)
        }
      },
      redirectTo(id) {
        window.location.href = `/tasks/otus/browse/${id}`
      }
    }
  }
</script>