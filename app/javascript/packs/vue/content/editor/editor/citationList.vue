<template>
  <div v-if="activeCitations && content && citations.length > 0">
    <ul>
      <li class="flex-separate middle" v-for="item, index in citations">{{ item.source.author_year }} <div @click="removeItem(index, item)" class="circle-button btn-delete">Remove</div>
      </li>
    </ul>
  </div>
</template>

<script>

  const GetterNames = require('../store/getters/getters').GetterNames;
  const MutationNames = require('../store/mutations/mutations').MutationNames;

    export default {
      computed: {
        citations() {
          return this.$store.getters[GetterNames.GetCitationsList]
        },
        content() {
          return this.$store.getters[GetterNames.GetContentSelected]
        },        
        activeCitations() {
          return this.$store.getters[GetterNames.PanelCitations]
        }
      },
      watch: {
        'content': function(val, oldVal) {
          if(val != undefined) {
            if (JSON.stringify(val) !== JSON.stringify(oldVal)) {
              this.loadContent();
            }
          }
          else {
            this.$store.commit(MutationNames.SetCitationList, []);
          }
        }
      },
      methods: {
        removeItem: function(index, item) {
          this.$http.delete("/citations/"+item.id).then( response => {
            this.$store.commit(MutationNames.RemoveCitation, index);
          });
        },
        loadContent: function() {
          var ajaxUrl;

          ajaxUrl = `/contents/${this.content.id}/citations`;
          this.$http.get(ajaxUrl, this.content).then(response => {
            this.$store.commit(MutationNames.SetCitationList, response.body);
          });
        }
      }
    };
</script>