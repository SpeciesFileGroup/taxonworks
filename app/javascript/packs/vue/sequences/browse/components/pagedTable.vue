<template>
    <div>
        <paged-table-header
            :maxItems="list.length"
            :initialPage="initialPage"
            :perPage="perPage"
            :pagesDisplayed="pagesDisplayed"
            :title="title"
            @newPage="newPage"
            @showAll="showAll">
        </paged-table-header>
        <table-list
            :list="pagedList"
            :attributes="attributes"
            :header="header"
            :destroy="destroy"
            :edit="edit"
            @delete="deleteCallback"
            @edit="editCallback">
        </table-list>
    </div>
</template>

<script>
    import pagedTableHeader from "./pagedTableHeader.vue";
    import tableList from "../../../components/table_list.vue";

    export default {
        data: function() {
            return {
                currentPage: this.initialPage,
                paginating: true
            }
        },
        props: {
            initialPage: {
                type: Number,
                default: 1
            },
            perPage: {
                type: Number,
                default: 25
            },
            pagesDisplayed: {
                type: Number,
                default: 9
            },
            title: {
                type: String,
                default: "Displaying"
            },
            list: {
				type: Array,
				default: () => { 
					return []
				}
			},
			attributes: {
				type: Array,
				required: true
			},
			header: {
				type: Array,
				default: () => {
					return []
				}
			},
			destroy: {
				type: Boolean,
				default: true
			},
			edit: {
				type: Boolean,
				default: false
			}
        },
        components: {
            pagedTableHeader,
            tableList
        },
        methods: {
            newPage: function(newPage) {
                this.currentPage = newPage;
                this.paginating = true;
            },
            showAll: function() {
                this.paginating = false;
            },
            deleteCallback: function(item) {
                this.$emit("delete", item);
            },
            editCallback: function(item) {
                this.$emit("edit", item);
            }
        },
        computed: {
            pagedList: function() {
                if(this.paginating) {
                    const begIndex = this.perPage * (this.currentPage - 1);
                    return this.list.slice(begIndex, begIndex + this.perPage);
                }

                else
                    return this.list;
            }
        }
    }
</script>