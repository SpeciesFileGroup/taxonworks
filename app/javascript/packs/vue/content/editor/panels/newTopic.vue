<template>
  <div>
    <button v-on:click="openWindow" class="button button-default normal-input">New</button>
    <modal v-if="showModal" @close="showModal = false">
      <h3 slot="header">New topic</h3>
      <form  id="new-topic" action="" slot="body">
        <div class="field flex-separate">
          <input type="text" v-model="topic.controlled_vocabulary_term.name" placeholder="Name" />
          <input type="color" v-model="topic.controlled_vocabulary_term.css_color" />
        </div>
        <div class="field">
          <textarea v-model="topic.controlled_vocabulary_term.definition" placeholder="Definition"></textarea>
        </div>
      </form>
      <div slot="footer" class="flex-separate">
        <input class="button normal-input" type="submit" v-on:click.prevent="createNewTopic" :disabled="((topic.controlled_vocabulary_term.name.length < 2) || (topic.controlled_vocabulary_term.definition.length < 2)) ? true : false" value="Create"/>
      </div>
    </modal>
  </div>
</template>

<script>
  const MutationNames = require('../store/mutations/mutations').MutationNames;
  const modal = require('../../../components/modal.vue');

  export default {
      data: function() { return {
        showModal: false,
        topic: {
          controlled_vocabulary_term: {
            name: '',
            definition: '',
            type: 'Topic',
            }
          }
        }
      },
      components: {
        modal
      },
      methods: {
        openWindow: function() {
          this.topic.controlled_vocabulary_term.name = '';
          this.topic.controlled_vocabulary_term.definition = '';
          this.showModal = true;          
        },
        createNewTopic: function() {
          var that = this;
          this.$http.post('/controlled_vocabulary_terms.json', this.topic).then( response => {
              TW.workbench.alert.create(response.body.name + " was successfully created.", "notice");
              that.$parent.topics.push(response.body);
              this.$store.commit(MutationNames.AddToRecentTopics, response.body)
          });
          this.showModal = false;
        }        
      }
    }; 
</script>