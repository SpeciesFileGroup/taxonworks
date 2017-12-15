<template>
	<div>
        <div class="panel column-big separate-right" data-help="Use the left and right buttoms to hide or show columns groups">
            <div class="title nav-line ">
                <span>{{ title }}<b> {{ getBegItemCount() }}&nbsp;-&nbsp;{{ getEndItemCount() }}</b> of <b>{{ this.maxItems }}</b></span>
            </div>      
            <div class="navigation-controls"> 
                <div class="navigation-bar-left">
                    <div class="page-navigator">
                        <span>
                            <a v-if="currentPage > 1" href="#" @click.prevent="prevPage">
                                ‹ Back
                            </a>
                            <template v-else>
                                ‹ Back
                            </template>
                        </span>
                        <span>
                            <a v-if="currentPage < totalPages" href="#" @click.prevent="nextPage">
                                Next ›
                            </a>
                            <template v-else>
                                Next ›
                            </template>
                        </span> 
                    </div>
                    <nav class="pagination" role="navigation" aria-label="pager">
                        <span v-if="begPage > 1" class="page gap">...</span>
                        <span v-for="i in range(begPage, endPage + 1)" :key="i" class="page" :class="{ current: i === currentPage }">
                            <template v-if="i === currentPage">
                                {{ i }}
                            </template>
                            <a v-else href="#" @click.prevent="selectPage(i)">{{ i }}</a>
                        </span>
                        <span v-if="endPage < totalPages" class="page gap">...</span>
                        <span v-if="currentPage > 1" class="first">
                            <a href="#" @click.prevent="selectPage(1)">« First</a>
                        </span>
                        <span v-if="currentPage < totalPages" class="last">
                            <a href="#" @click.prevent="selectPage(totalPages)">Last »</a>
                        </span>
                    </nav>
                </div>
            </div>       
        </div>
    </div>
</template>
<script>
    export default {
        props: {
            maxItems: {
                type: Number,
                required: true
            },
            initialPage: {
                type: Number,
                default: 1
            },
            perPage: {
                type: Number,
                default: 1
            },
            pagesDisplayed: {
                type: Number,
                default: 9
            },
            title: {
                type: String,
                default: "Displaying"
            }
        },
        data: function() {
            return {
                currentPage: this.initialPage,
                totalPages: Math.ceil(this.maxItems / this.perPage),
                begPage: 0,
                endPage: 0
            }
        },
        mounted: function() {
            this.updatePageBoundaries();
        },
        methods: {
            prevPage: function() {
                this.$emit("newPage", --this.currentPage);
            },
            nextPage: function() {
                this.$emit("newPage", ++this.currentPage)
            },
            selectPage: function(newPage) {
                this.currentPage = newPage;
                this.$emit("newPage", this.currentPage);
            },
            getBegItemCount: function() {
                let begItemCount = (this.currentPage * this.perPage) - (this.perPage - 1);

                if(this.maxItems <= 0)
                    begItemCount = 0;
                
                return begItemCount;
            },
            getEndItemCount: function() {
                let endItemCount = this.currentPage * this.perPage;

                if(endItemCount > this.maxItems)
                    endItemCount = this.maxItems;

                return endItemCount;
            },
            range: function(beg, end) {
                let arr = [];

                for(let i = beg; i < end; i++)
                    arr.push(i);

                return arr;
            },
            updatePageBoundaries: function() {
                const half = Math.floor(this.pagesDisplayed / 2);
                this.begPage = this.currentPage - half
                this.endPage = this.currentPage + half;

                if(this.begPage < 1)
                    this.begPage = 1

                if(this.endPage > this.totalPages)
                    this.endPage = this.totalPages;
            }
        },
        watch: {
            currentPage: function() {
                this.updatePageBoundaries();
            },
            maxItems: function() {
                this.totalPages = Math.ceil(this.maxItems / this.perPage);
                this.updatePageBoundaries();
            }
        }
    }
</script>
