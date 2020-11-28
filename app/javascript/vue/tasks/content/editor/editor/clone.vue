<template>
  <div :class="{ disabled : contents.length == 0 }">
    <div
      @click="showModal = true && contents.length > 0"
      class="item flex-wrap-column middle menu-button">
      <span
        data-icon="clone"
        class="big-icon"/>
      <span class="tiny_space">Clone</span>
    </div>
    <modal
      v-if="showModal"
      id="clone-modal"
      @close="showModal = false">
      <h3 slot="header">Clone</h3>
      <div slot="body">
        <ul class="no_bullets">
          <li
            v-for="item in contents"
            @click="cloneCitation(item.text)">
            <span data-icon="show">
              <div class="clone-content-text">{{ item.text }}</div>
            </span>
            <span v-html="item.object_tag"/>
          </li>
        </ul>
      </div>
    </modal>
  </div>
</template>

<script>

import { GetterNames } from '../store/getters/getters'
import { GetContents } from '../request/resources'
import Modal from 'components/modal.vue'

export default {
  components: {
    Modal
  },
  data () {
    return {
      contents: [],
      showModal: false
    }
  },
  name: 'CloneConent',
  computed: {
    disabled () {
      return (this.$store.getters[GetterNames.GetContentSelected] == undefined)
    },
    topic () {
      return this.$store.getters[GetterNames.GetTopicSelected]
    },
    content () {
      return this.$store.getters[GetterNames.GetContentSelected]
    },
    otu () {
      return this.$store.getters[GetterNames.GetOtuSelected]
    }
  },
  watch: {
    content (val, oldVal) {
      if (val != undefined) {
        if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
          this.loadContent()
        }
      } else {
        this.contents = []
      }
    }
  },
  methods: {
    loadContent () {
      if (this.disabled) return

      GetContents({ topic_id: this.topic.id }).then(response => {
        this.contents = response.body.filter(c => c.id !== this.content.id)
      })
    },
    cloneCitation: function (text) {
      this.$emit('addCloneCitation', text)
      this.showModal = false
    }
  }
}
</script>
