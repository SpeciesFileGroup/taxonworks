<template>
  <div class="figures-container" :class="{ 'card-handle' : !edit }">
    <div class="figures-header">
      <img :src="depiction.image.result.url" />
      <div class="button-delete circle-button figures-delete" @click="deleteDepiction()"></div>
      <div :class="{ 'button-submit' : edit, 'button-default' : !edit }" class="circle-button figures-edit" @click="editChange()"></div>
      <input class="figures-label horizontal-center-content middle" v-if="edit" type="text" v-model="depiction.figure_label"/>
      <div class="figures-label horizontal-center-content middle" v-else> {{ depiction.figure_label }} </div>
    </div>
    <div class="figures-body">
      <textarea v-model="depiction.caption" v-if="edit"></textarea>
      <span v-else>{{ depiction.caption }}</span>
    </div>
  </div>
</template>
<script>

  const MutationNames = require('../store/mutations/mutations').MutationNames;

  export default {
      props: ['figure'],
      name: 'figure-item',
      data: function() { 
        return {
          depiction: undefined,
          edit: false
        }
      },
      watch: {
        'figure': function(newVal) {
          this.depiction = newVal;
        }
      },
      created: function() {
        this.depiction = this.figure;
      },
      methods: {
        deleteDepiction: function() {
          var ajaxUrl = `/depictions/${this.depiction.id}`;
          this.$http.delete(ajaxUrl).then( response => {
            this.$store.commit(MutationNames.RemoveDepiction, this.depiction);
          })
        },
        editChange: function() {
          if(this.edit) {
            this.update();
          }
          this.edit = !this.edit;
        },
        update: function() {
          var ajaxUrl = `/depictions/${this.depiction.id}`,
              depiction = {
                caption: this.depiction.caption,
                figure_label: this.depiction.figure_label
              };


          this.$http.patch(ajaxUrl, depiction).then( response => {
            TW.workbench.alert.create("Depiction was successfully updated.", "notice");
          })
        }
      }
  };
</script>