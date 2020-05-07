<template>
  <div class="otu-radial">
    <span 
      class="circle-button button-default"
      :title="redirect ? 'Browse taxa' : 'OTU quick forms'"
      :class="[{ 'button-submit': emptyList }, (redirect ? 'btn-hexagon-empty-w' : 'btn-hexagon-w')]"
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
    <otu-radial
      ref="annotator"
      type="graph"
      :show-bottom="false"
      :global-id="globalId"/>
  </div>
</template>

<script>

  import Modal from '../modal.vue'
  import Spinner from '../spinner.vue'
  import OtuRadial from 'components/radials/object/radial'
  import { GetOtus, CreateOtu } from './request/resources'

  export default {
    components: {
      Modal,
      Spinner,
      OtuRadial
    },
    props: {
      taxonId: {
        type: [String, Number],
        required: false
      },
      otu: {
        type: Object,
        default: undefined
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
        loaded: false,
        list: []
      }
    },
    mounted() {
      if(!this.otu && this.taxonId) {
        this.getOtuList()
      }
      else {
        this.list.push(this.otu)
        this.loaded = true
      }
      document.addEventListener("vue-otu:created", (event) => {
        if(this.taxonId == event.detail.taxonId)
          this.list = event.detail.list
      })
    },
    methods: {
      getOtuList() {
        GetOtus(this.taxonId).then(response => {
          this.loaded = true
          this.list = response
        })
      },
      openApp() {
        if(this.loaded) {
          if(this.emptyList) {
            this.createOtu(this.taxonId);
          }
          else if(this.list.length === 1) {
            this.processCall(this.list[0])
          }
          else {
            this.modalOpen = true
          }
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
          this.list.push(response)
          this.sendCreatedEvent()
          if(this.redirect) {
            this.redirectTo(response.id)
          }
          else {
            this.openRadial(response)
          }
        }) 
      },
      sendCreatedEvent() {
        let event = new CustomEvent("vue-otu:created", {
          detail: {
            taxonId: this.taxonId,
            list: this.list
          }
        });
        document.dispatchEvent(event)
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
<style lang="scss">
  .otu-radial {
    .circle-count {
      bottom: -2px !important;
    }
  }
</style>
