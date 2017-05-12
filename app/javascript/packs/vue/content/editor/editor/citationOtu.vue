<template>
  <div :class="{ disabled : disabled  }">
    <div class="flex-wrap-column middle menu-button" @click="showModal = citations.length > 0"><span data-icon="citation" class="big-icon"></span><span class="tiny_space">OTU Citation</span></div>
    <modal v-if="showModal" @close="showModal = false">
      <h3 slot="header">Citation OTU</h3>
      <ul slot="body">
        <li v-for="item in citations"><span @click="pinItem(item)"></span><span v-html="item.object_tag"></span></li>
      </ul>
    </modal>
  </div>
</template>    

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const modal = require('../../../components/modal.vue');

  export default {
    computed: {
      otu() {
        return this.$store.getters[GetterNames.GetOtuSelected]
      },       
      topic() {
        return this.$store.getters[GetterNames.GetTopicSelected]
      },
      disabled() {
        return (this.$store.getters[GetterNames.GetTopicSelected] == undefined || this.$store.getters[GetterNames.getOtuSelected] == undefined)
      },              
    },
    components: {
      modal
    },
    data: function() {
      return {
        showModal: false,
        citations: []
      }
    },
    watch: {
      'otu': function(val, oldVal) {
        if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
          this.loadContent();
        }
      }
    },
    methods: {
      pinItem: function(item) {
        var pinboard_item = {
          pinned_object_id: item.source.id,
          pinned_object_type: "Source"
        }

        this.$http.post("/pinboard_items.json", pinboard_item).then( response => {
          TW.workbench.alert.create("Pinboard item was successfully created.", "notice");
        }, response => {
          TW.workbench.alert.create(item.source.object_tag + " already pinned.", "alert");
        });            
      },
      loadContent: function() {
        if (this.disabled) return

          var that = this;
        ajaxUrl = `/otus/${this.otu.id}/citations.json?topic_id=${this.topic.id}`

        this.$http.get(ajaxUrl).then( response => {
          that.citations = response.body;         
        });          
      },
    }
  };
</script>