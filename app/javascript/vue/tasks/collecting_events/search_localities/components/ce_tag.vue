<template>
  <div class="find-ce">
    <h3>Find collecting events</h3>
    <div>
      <table>
        <tr
          v-for="(item, index) in tagList"
          :key="item.id">
          <td>
            <a
              v-html="item.label_html"
              @click="showObject()"/>
          </td>
          <td><span @click="delistMe(index)">(Remove)</span></td>
        </tr>
      </table>
    </div>
     <autocomplete
      class="separate-bottom"
      url="/controlled_vocabulary_terms/autocomplete"
      min="2"
      ref="autocomplete"
      :add-params="{'of_type[]' : 'Keyword'}"
      param="term"
      placeholder="Select a tag"
      label="label"
      @getItem="addTag($event)"
      :autofocus="true"
      :clear-after="true"/>
    <input
      type="button"
      @click="getTagData()"
      value="Find">
    <div>
      <table>
        <tr
          v-for="item in collectingEventList"
          :key="item.id">
          <td>
            <span
              v-html="item.id + ' ' + item.label_html"/>
          </td>
        </tr>
      </table>
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
        tagList: [],
        collectingEventList: [],
      }
    },

    methods: {
      getTagData(){
        let tag_ids = [];
        this.tagList.forEach(tag => {
          tag_ids.push(tag.id)
        });
        let params = {
          keyword_ids: tag_ids
        };
        this.$http.get('/collecting_events', {params: params}).then(response => {
          this.collectingEventList = response.body.html;
        });
      },
      addTag(item) {
        this.tagList.push(item);
      },
      showObject() {
        return true
      },
      delistMe(index) {
        this.$delete(this.tagList, index)
      },
    }
  }
</script>
