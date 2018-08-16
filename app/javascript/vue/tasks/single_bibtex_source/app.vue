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
            @click="createSource"
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
            <table-bibtex :bibtex="parsedBibtex"/>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import BibtexInput from "./components/bibtex_input"
import TableBibtex from './components/tableBibtex'
import Spinner from "../../components/spinner.vue"

export default {
  components: {
    BibtexInput,
    TableBibtex,
    Spinner
  },
  computed: {
    enableParseBibtex() {
      return this.bibtexInput.length > 0;
    },
    enableCreateBibtex() {
      return (!this.parsedBibtex.hasOwnProperty('status') && Object.keys(this.parsedBibtex).length); //Object.keys(this.parsedBibtex).length;
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
      parsedBibtex: {},
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
      }
      this.isLoading = true;
      this.$http.get("/sources/parse.json", { params: params }).then(response => {
        this.parsedBibtex = response.body; 
        this.unlockCreate = !response.body.hasOwnProperty('status');
        this.isLoading = false;
      });
    },
    resetApp() {
      this.bibtexInput = '';
      this.clearParsedData();
    },
    createSource() {
      this.isLoading = true;
      this.$http.post("/sources.json", { bibtex_input: this.bibtexInput }).then(response => {
        this.parsedBibtex = response.body;
        this.bibtexInput = ""
        this.isLoading = false;
      });     
    }
  }
}
</script>
