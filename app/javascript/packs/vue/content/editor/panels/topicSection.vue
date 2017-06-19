<template>
  <div id="topics" class="slide-panel slide-left slide-recent" data-panel-position="relative" v-if="active" data-panel-open="true" data-panel-name="topic_list">
    <div class="slide-panel-header flex-separate">Topic list<new-topic></new-topic></div>
    <div class="slide-panel-content">
      <div class="slide-panel-category">
        <ul class="slide-panel-category-content">
          <li v-for="item, index in topics" class="slide-panel-category-item" :class="{ selected : (index == selected) }"v-on:click="loadTopic(item,index)"> {{ item.name }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>    
<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const newTopic = require('./newTopic.vue');

  export default {
    data: function() { 
      return {
        selected: -1,
        topics: []
      }
    },
    components: {
      newTopic
    },
    computed: {
      active() {
        return this.$store.getters[GetterNames.ActiveTopicPanel];
      }
    },
    mounted: function() {
      this.loadList();
    },
    methods: {
      loadTopic: function(item, index) {
        this.selected = index
        this.$store.commit(MutationNames.SetTopicSelected, item);
        TW.views.shared.slideout.closeHideSlideoutPanel('[data-panel-name="topic_list"]');
      },       
      loadList: function() {
        var that;
        that = this;
        this.$http.get('/topics/list').then( response => {
          that.topics = response.body;
        });         
      }
    }
  };
</script>