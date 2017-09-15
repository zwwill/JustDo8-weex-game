<template>
    <text class="u-stone" :style="{left:x,bottom:y,color:color,backgroundColor:backgroundColor}" v-if="score!=0">{{score}}</text>
</template>

<style scoped>
    .u-stone{
        width: 125px;
        height: 125px;
        border-bottom-width: 10px;
        border-bottom-color: rgba(0,0,0,0.3);
        line-height: 125px;
        text-align: center;
        font-size: 80px;
        color: #666;
        background-color: #ddd;
        position: absolute;
    }
</style>

<script>

    export default {
        props: {
            p: {
                type: String,
                default: "00"
            },
            num: {
                type: Number,
                default: 1
            }
        },
        data(){
            return {
                colors:             ["#666","#666","#eee","#b9e3ee","#ebe94b","#46cafb","#eca48f","#decb3d","#8d1894"],
                backgroundColors:   ["#ddd","#ddd","#999","#379dc3","#36be0d","#001cc6","#da4324","#56125a","#ffffff"]
            }
        },
        computed: {
            x: function () {
                return 125*this.p.charAt(0)+"px";
            },
            y: function () {
                return 125*this.p.charAt(1)+"px";
            },
            color: function () {
                return this.colors[this.score];
            },
            backgroundColor: function () {
                return this.backgroundColors[this.score];
            },
            score: function () {
                return this.num<9&&this.num>0?this.num:0
            }
        },
        methods: {

        }
    }
</script>