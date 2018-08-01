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
            @click="parseBibtex"
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
      return Object.keys(this.parsedBibtex).length;
    }
  },
  data() {
    return {
      bibtexInput: "",
      isLoading: false,
      parsedBibtex: {},
      parsedValid: false
    };
  },
  watch: {
    // bibtexInput() {
    //   this.parsedBibtex = {};
    //   this.isLoading = true;
    // },
    parsedBibtex() {
      this.isLoading = false;
    }
  },
  methods: {
    parseBibtex() {
      let params = {
        bibtex_input: this.bibtexInput
      };
      this.isLoading = true;
      let that = this;
      this.$http.get("/sources/parse.json", { params: params }).then(response => {
        this.parsedBibtex = response.body;
        this.parsedValid = response.status == "OK";
        that.isLoading = false;
      });
    },
    createBibtex() {
      let params = {
        parsed_bibtex: this.parsedBibtex.value
      };
      this.$http
        .post("/source/create", params)
        .then(response => {
          let httpStatus = response.body;
          if (httpStatus.status == "OK") {
            // delete the merged in person and refresh the merged to person
            this.$http
              .delete("/people/" + this.parsedBibtex.id)
              .then(response => {
                this.$refs.matchPeople.removeFromList(this.parsedBibtex.id); // remove the merge person from the matchPerson list
                this.$refs.foundPeople.removeFromList(this.parsedBibtex.id); // remove the merge person from the foundPerson list
                this.parsedBibtex = {};
              });
          } else {
            // TODO: Annunciate delete failure more gracefully
            alert(httpStatus.status);
            this.parsedBibtex = {};
          }
        });
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
