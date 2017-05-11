<template>
  <div>
    <button @click="showModal = true" class="button normal-input button-default">Select</button>
    <modal v-if="showModal" @close="showModal = false">
      <h3 slot="header">Select</h3>
      <div slot="body">
        <div class="flex-wrap-column middle">
          <button @click="closeAll(), topicPanel()" class="button button-default button-select">
            <span v-if="topic">Change topic</span>
            <span v-else>Topic</span>
          </button>
          <button @click="closeAll(), otuPanel()" class="button button-default separate-top button-select">
            <span v-if="otu">Change OTU</span>
            <span v-else>OTU</span>
          </button>
          <button @click="closeAll(), recentPanel()" class="button button-default separate-top button-select">
            <span>Recent</span>
          </button>
        </div>
      </div>
    </modal>
  </div>
</template>

<script>
  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const modal = require('../../../components/modal.vue');

  export default {
      data: function() {
        return {
          showModal: true,
          selectedPanel: '',
        }
      },
      name: 'select-topic-otu',
      components: {
        modal
      },
      computed: {
        topic() {
          return this.$store.getters[GetterNames.GetTopicSelected]
        },
        otu() {
          return this.$store.getters[GetterNames.GetOtuSelected]
        }        
      },
      watch: {
        topic: function(val, oldVal) {
          if(val !== oldVal) {
            if(this.otu) {
              this.showModal = false;
            }
          }
          this.closeAll();          
        },
        otu: function(val, oldVal) {
          if(val !== oldVal) {            
            if(this.topic) {
              this.showModal = false;
            }
          }          
          this.closeAll();
        }
      },
      methods: {
        closeAll: function() {
          TW.views.shared.slideout.closeSlideoutPanel('[data-panel-name="recent_list"]');
          TW.views.shared.slideout.closeSlideoutPanel('[data-panel-name="topic_list"]');
          this.$store.commit(MutationNames.OpenOtuPanel, false);
        },
        topicPanel: function() {
          TW.views.shared.slideout.openSlideoutPanel('[data-panel-name="topic_list"]');
        },
        recentPanel: function() {
          TW.views.shared.slideout.openSlideoutPanel('[data-panel-name="recent_list"]');          
        },
        otuPanel: function() {
          this.$store.commit(MutationNames.OpenOtuPanel, true);         
        }        
      }
    };
</script>