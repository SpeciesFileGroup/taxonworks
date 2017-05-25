<template>
  <div v-if="!disabled" class="content">
    <div class="content flex-wrap-row" id="topic-list">
      <ul class="flex-wrap-column no_bullets" v-for="itemsGroup in items.chunk(Math.ceil(items.length/4))">
        <li class="topics" v-for="item in itemsGroup"><topic-checkbox v-bind:topic="item"> </topic-checkbox></li>
      </ul>
    </div>
  </div>
</template>
<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const topicCheckbox = require('./topicCheckbox.vue');

  export default {
    computed: {
      items() {
        return this.$store.getters[GetterNames.GetTopicsList]
      },
      disabled() {
        return this.$store.getters[GetterNames.ObjectsSelected]
      }
    },
    components: {
      topicCheckbox
    }
  };
</script>