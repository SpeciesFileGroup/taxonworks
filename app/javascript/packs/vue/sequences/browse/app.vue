<template>
    <div id="browse_sequences">
        <autocomplete
            id="gene_autocomplete"
            url="/descriptors/autocomplete" 
            param="term" 
            min="1" 
            label="label"
            placeholder="Enter Gene name"
            @getItem="loadGene">
        </autocomplete>
        <paged-table
            title="Displaying sequences"
            :list="list"
            :header="header"
            :attributes="attributes"
            :edit="true"
            :destroy="false"
            @edit="editSequence">
        </paged-table>
    </div>
</template>

<script>
    import autocomplete from "../../components/autocomplete.vue";
    import pagedTable from "./components/pagedTable.vue";

    export default {
        components: {
            autocomplete,
            pagedTable
        },
        data: function() {
            return {
                list: [],
                header: [
                    "Name"
                ],
                attributes: [
                    "name"
                ]
            }
        },
        methods: {
            loadGene: function (gene) {
                this.$http.get("/tasks/sequence/browse/sequences?gene_id=" + gene.id).then(res => {
                    this.list = res.body;
                });
            },
            editSequence: (sequence) => {
                window.location.href = "/sequences/" + sequence.id;
            }
        }
    }
</script>

<style scoped>
    #gene_autocomplete {
        margin-bottom: 5px;
    }
</style>
