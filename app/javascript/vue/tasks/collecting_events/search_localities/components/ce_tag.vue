<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <autocomplete
      class="separate-bottom"
      url="/controlled_vocabulary_terms/autocomplete"
      min="2"
      ref="autocomplete"
      :add-params="{'of_type[]' : 'Keyword'}"
      param="term"
      placeholder="Select a tag"
      label="label"
      @getItem="sendTag($event)"
      :autofocus="true"
      :clear-after="true"/>
    <input type="button" @click="emitTagData()" title="Find">
    <div>
      <span
        v-for="item in tagList"
        v-html="item.verbatim_locality"></span>
      <div>{{ tagList }}</div>
  </div>
  </div>
</template>
<script>
  import Autocomplete from 'components/autocomplete'
  export default {
    components: {
      Autocomplete,
    },
    data() {
      return {
        tagList: []
      }
    },

    methods: {
      emitTagData(){
        let params = {
        };
        this.$http.get('/collecting_events', {params: params}).then(response => {
          this.tagList = response.body.html;
        });
      },
      sendTag(item) {
        this.selected = '';
        this.$emit('select', item.id)
      },
    }
  }
</script>
