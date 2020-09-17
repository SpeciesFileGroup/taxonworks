<template>
  <div
  :class="{ disabled : !content || contents.length < 1}">
    <div
      class="item flex-wrap-column middle menu-button"
      @click="showModal = contents.length > 0">
      <span
        data-icon="compare"
        class="big-icon"/>
      <span class="tiny_space">Compare</span>
    </div>
    <modal
      v-if="showModal"
      id="compare-modal"
      @close="showModal = false">
      <h3 slot="header">Compare content</h3>
      <ul
        slot="body"
        class="no_bullets">
        <li
          v-for="item in contents"
          @click="compareContent(item)">
          <span data-icon="show">
            <div class="clone-content-text">{{ item.text }}</div>
          </span>
          <span v-html="item.topic.object_tag + ' - ' + item.otu.object_tag"/>
        </li>
      </ul>
    </modal>
  </div>
</template>

<script>

  import { GetterNames } from '../store/getters/getters'
  import removeDuplicate from '../helpers/removeDuplicate'
  import Modal from 'components/modal.vue'
  import AjaxCall from 'helpers/ajaxCall'

  export default {
    data: function () {
      return {
        contents: [],
        showModal: false
      }
    },
    components: {
      Modal
    },
    computed: {
      topic() {
        return this.$store.getters[GetterNames.GetTopicSelected]
      },
      content() {
        return this.$store.getters[GetterNames.GetContentSelected]
      },
      disabled() {
        return (this.$store.getters[GetterNames.GetTopicSelected] == undefined || this.$store.getters[GetterNames.GetOtuSelected] == undefined)
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
      loadContent: function () {
        if (this.disabled) return

        let that = this,
          ajaxUrl = `/contents/filter.json?topic_id=${this.topic.id}`

        AjaxCall('get', ajaxUrl).then(response => {
          that.contents = removeDuplicate(response.body, this.content.id)
        })
      },
      compareContent: function (content) {
        this.$parent.$emit('showCompareContent', content)
        this.showModal = false
      }
    }
  }
</script>
