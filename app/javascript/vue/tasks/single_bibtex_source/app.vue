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
            <bibtex-input v-model="bibtexInput" />
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
          <br>
          <br>
          <span>{{ showCreatedSourceID }}</span>
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
      return (this.parsedBibtex.valid && this.unlockCreate); //Object.keys(this.parsedBibtex).length;
    },
    showCreatedSourceID() {
      let retVal = '';
      if(this.parsedBibtex.source) {
        if(this.parsedBibtex.source.id) {
          retVal = "Created Source: " + this.parsedBibtex.source.id;
        }
      }
      return retVal;
    }
  },
  data() {
    return {
      bibtexInput: "",
      isLoading: false,
      parsedBibtex: '',
      unlockCreate: false,
    };
  },
  watch: {
    parsedBibtex() {
      this.isLoading = false;
    }
  },
  methods: {
    parseBibtex(create) {
      let params = {
        bibtex_input: this.bibtexInput,
        create_bibtex: create
      };
      this.isLoading = true;
      let that = this;
      this.$http.get("/sources/parse.json", { params: params }).then(response => {
        this.parsedBibtex = response.body;
        this.unlockCreate = this.parsedBibtex.valid && !create;
        that.isLoading = false;
      });
    },
    createBibtex() {
      let create = true;      // just for clarity
      this.parseBibtex(create);
      this.unlockCreate = false;
    },
    resetApp() {
      this.clearInputData();
    },
    clearInputData() {
      this.bibtexInput = '';
      this.clearParsedData();
    },
    clearParsedData() {
      this.parsedBibtex = '';
    }
  }
};
</script>
