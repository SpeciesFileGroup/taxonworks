import { defineStore } from "pinia";
import { TaxonName, Source, Citation } from "@/routes/endpoints";
import AjaxCall from "@/helpers/ajaxCall";

export default defineStore("verbatimAuthorYearSource", {
  state: () => ({
    authorYearData: [],
    maxCount: 1,
    isLoading: false,
    recentSources: [],
    previewTaxonNames: [],
    filterParams: {},
  }),

  getters: {
    hasData(state) {
      return state.authorYearData.length > 0;
    },

    activeRows(state) {
      return state.authorYearData.filter((row) => !row.isCited);
    },

    highestCountRow(state) {
      const active = this.activeRows;
      if (active.length === 0) return null;

      return active.reduce(
        (max, row) => (row.record_count > max.record_count ? row : max),
        active[0],
      );
    },
  },

  actions: {
    async loadAuthorYearData(params = {}) {
      this.isLoading = true;
      this.filterParams = params;

      try {
        const response = await AjaxCall(
          "get",
          "/tasks/sources/verbatim_author_year_source.json",
          { params },
        );

        this.authorYearData = response.body.data.map((row) => ({
          verbatim_author: row.verbatim_author,
          year_of_publication: row.year_of_publication,
          record_count: row.record_count,
          heat_color: row.heat_color,
          isCited: false,
          isPending: false,
          pendingStage: null,
          progressCurrent: 0,
          progressTotal: 0,
        }));

        this.maxCount = response.body.max_count;
      } catch (error) {
        console.error("Error loading author/year data:", error);
        TW.workbench.alert.create("Error loading data", "error");
      } finally {
        this.isLoading = false;
      }
    },

    async loadRecentSources() {
      try {
        const response = await Source.where({ per: 10, recent: true });
        this.recentSources = response.body;
        return response.body;
      } catch (error) {
        console.error("Error loading recent sources:", error);
        throw error;
      }
    },

    async loadPreviewTaxonNames(author, year) {
      try {
        const response = await TaxonName.where({
          author: author,
          author_exact: true,
          year_of_publication: year,
        });
        this.previewTaxonNames = response.body;
        return response.body;
      } catch (error) {
        console.error("Error loading preview TaxonNames:", error);
        throw error;
      }
    },

    async batchCite(author, year, sourceId) {
      // Find the row to update
      const row = this.authorYearData.find(
        (r) => r.verbatim_author === author && r.year_of_publication === year,
      );

      if (!row) {
        console.error("Row not found for author:", author, "year:", year);
        return;
      }

      row.isPending = true;
      row.pendingStage = "citations";
      row.progressCurrent = 0;
      row.progressTotal = 0;

      try {
        // Get TaxonName IDs
        const taxonNamesResponse = await TaxonName.where({
          author: author,
          author_exact: true,
          year_of_publication: year,
        });

        const taxonNames = taxonNamesResponse.body;
        const ids = taxonNames.map((tn) => tn.id);

        // Validate we have the expected count
        if (ids.length === 0) {
          throw new Error("No TaxonNames found for this author/year");
        }

        if (ids.length !== row.record_count) {
          throw new Error(
            `Expected ${row.record_count} TaxonNames but found ${ids.length}`,
          );
        }

        // Stage 1: Create citations
        row.progressTotal = ids.length;
        row.progressCurrent = 0;

        await Citation.createBatch({
          citation: {
            citation_object_type: "TaxonName",
            citation_object_id: ids,
            source_id: sourceId,
            is_original: true,
          },
        });

        row.progressCurrent = ids.length;

        // Stage 2: Clear verbatim_author from TaxonNames
        row.pendingStage = "updating";
        row.progressCurrent = 0;

        for (let i = 0; i < ids.length; i++) {
          await TaxonName.update(ids[i], {
            taxon_name: { verbatim_author: null, year_of_publication: null },
          });
          row.progressCurrent = i + 1;
        }

        // Mark as complete
        row.isCited = true;
        row.isPending = false;
        row.pendingStage = null;

        TW.workbench.alert.create(
          "Citations created and taxon names updated",
          "notice",
        );
      } catch (error) {
        console.error("Error in batch cite:", error);
        row.isPending = false;
        row.pendingStage = null;
        TW.workbench.alert.create(
          error.message || "Error creating citations",
          "error",
        );
        throw error;
      }
    },

    resetPreview() {
      this.previewTaxonNames = [];
    },
  },
});
