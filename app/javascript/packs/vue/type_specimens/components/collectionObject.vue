<template>
  <div>
    <div class="field">
      <label>Total</label>
      <input type="number"/>
    </div>
    <div class="field">
      <select>
        <option v-for="item, index in types" :value="(index+1)">{{ item }}</option>
      </select>
    </div>
    <div class="field">
      <label>Repository</label>
      <autocomplete
        url="/repositories/autocomplete"
        param="term"
        label="label_html"
        placeholder="Select a repository"
        @getItem="protonymId = $event.id"
        display="label"
        min="2">
      </autocomplete>
    </div>
    <div class="field">
      <label>Collection event</label>
      <autocomplete
        url="/collection_events/autocomplete"
        param="term"
        label="label_html"
        placeholder="Select a collection event"
        @getItem="protonymId = $event.id"
        display="label"
        min="2">
      </autocomplete>
    </div>
    <div class="field">
      <label>Accessioned at</label>
      <input type="date"/>
    </div>
    <div class="field">
      <label>Deaccessioned at</label>
      <input type="date"/>
    </div>
    <div class="field">
      <label>Deaccession reason</label>
      <input type="text" />
    </div>
    <div class="field">
      <label>Buffered collecting event</label>
      <textarea></textarea>
    </div>
    <div class="field">
      <label>Buffered determinations</label>
      <textarea></textarea>
    </div>
    <div class="field">
      <label>Buffered other labels</label>
      <textarea></textarea>
    </div>
    <div class="field">
      <button type="button" class="button normal-input button-submit">Create Collection object</button>
    </div>
  </div>
</template>

<script>
  
  import autocomplete from '../../components/autocomplete.vue';

  export default {
    components: {
      autocomplete
    },
    data: function() {
      return {
        types: ['Bulk dry',
                'Envelope', 
                'Pill box', 
                'Jar', 
                'Pin', 
                'Slide', 
                'Vial']

      }
    }
  }
</script>