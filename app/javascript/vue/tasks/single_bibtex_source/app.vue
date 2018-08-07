<template>
  <div>
    <div class="flex-separate middle">
      <h1>New source from BibTeX</h1>
      <span
        @click="resetApp"
        class="reload-app"
        data-icon="reset">Reset
      </span>
    </div>
    <spinner
      v-if="isLoading"
      :full-screen="true"
      legend="Loading..."
      :logo-size="{ width: '100px', height: '100px'}"/>
    <div class="flexbox">
      <div class="flexbox">
        <div style="width: 200px">
          <div class="last_name separate-right">
            <h2>BibTeX Input</h2>
            <bibtex-input v-model="bibtexInput"/>
          </div>
          <br>
          <br>
          <br>
          <button
            class="button normal-input button-default"
            @click="parseBibtex(false)"
            :disabled="!enableParseBibtex"
            type="submit">Parse BibTeX
          </button>
          &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
          <button
            class="button normal-input button-default"
            @click="createBibtex"
            :disabled="!enableCreateBibtex"
            type="submit">Create source from BibTeX
          </button>
        </div>
        <div
          class="flex-separate top">
          <div
            style="overflow: auto; width:300px; height:800px;">
            <h2>Parsed BibTeX</h2>
            <pre>{{ parsedBibtex }}</pre>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
// TODO:  Revise queries to bias toward last name
//        Add alternate values for names
import BibtexInput from "./components/bibtex_input";

import Spinner from "../../components/spinner.vue";

export default {
  components: {
    BibtexInput,
    Spinner
  },
  computed: {
    enableParseBibtex() {
      return this.bibtexInput.length > 0;
    },
    enableCreateBibtex() {
      return (this.parsedBibtex.valid && this.parsedValid); //Object.keys(this.parsedBibtex).length;
    }
  },
  data() {
    return {
      bibtexInput: "",
      isLoading: false,
      parsedBibtex: {},
      parsedValid: false,
    };
  },
  watch: {
    parsedBibtex() {
      this.isLoading = false;
    }
  },
  methods: {
// TODO: refactor submit methods to combine function
    parseBibtex(create) {
      let params = {
        bibtex_input: this.bibtexInput,
        create_bibtex: create
      };
      this.isLoading = true;
      this.parsedValid = false;
      let that = this;
      this.$http.get("/sources/parse.json", { params: params }).then(response => {
        // if(!create) { this.parsedBibtex = response.body; }
        // if(create) {this.parsedValid = false}
        this.parsedBibtex = response.body;
        this.parsedValid = this.parsedBibtex.valid && !create;
        that.isLoading = false;
      });
    },
    createBibtex() {
      let create = true;      // just for clarity
      this.parsedBibtex = {};
      this.parsedValid = false;
      this.isLoading = false;
      this.parseBibtex(create);
      this.bibtexInput = '';    // doesn't actually clear it but makes it look empty to app.vue
      this.parsedBibtex = {};
      this.parsedValid = false;
    },
    resetApp() {
      this.clearFormData();
    },
    clearFormData() {
      this.bibtexInput = "";
      this.clearParsedData();
    },
    clearParsedData() {
      this.parsedBibtex = {};
    }
  }
};
</script>
