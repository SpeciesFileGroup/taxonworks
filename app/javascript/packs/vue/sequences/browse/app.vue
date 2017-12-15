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
        <paged-table-header title="Displaying sequences" :maxItems="list.length" :perPage="itemsPerPage" @newPage="newPage"></paged-table-header>
        <table-list :list="slicedList" :header="header" :attributes="attributes" :edit="true" :destroy="false" @edit="editSequence">
        </table-list> 
    </div>
</template>

<script>
    import tableList from "../../components/table_list.vue";
    import autocomplete from "../../components/autocomplete.vue";
    import pagedTableHeader from "./components/pagedTableHeader.vue";

    export default {
        components: {
            tableList,
            autocomplete,
            pagedTableHeader
        },
        data: function() {
            return {
                itemsPerPage: 25,
                currentPage: 1,
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
            },
            newPage: function(newPage) {
                this.currentPage = newPage;
            }
        },
        computed: {
            slicedList: function() {
                const begIndex = this.itemsPerPage * (this.currentPage - 1);

                return this.list.slice(begIndex, begIndex + this.itemsPerPage);
            }
        }
    }
</script>

<style scoped>
    #gene_autocomplete {
        margin-bottom: 5px;
    }
</style>
