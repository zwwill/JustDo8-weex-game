<template>
    <text ref="stone" class="u-stone" :style="{color:color,backgroundColor:backgroundColor,visibility:visibility}" v-if="score!=0" >{{score}}</text>
</template>

<style scoped>
    .u-stone{
        width: 126px;
        height: 125px;
        border-bottom-width: 10px;
        border-bottom-color: rgba(0,0,0,0.3);
        line-height: 125px;
        text-align: center;
        font-size: 80px;
        color: #666;
        background-color: #ddd;
        position: absolute;
        left: 0;
        bottom: 0;
        transform: translate(0px,-875px);
        opacity: 0.8;
        /*visibility: hidden;*/
    }
</style>

<script>
    const animation = weex.requireModule('animation')
    export default {
        props: ['id', 'p0', 'num0'],
        data(){
            return {
                p: '0,7',
                visibility: '',
                num: 1,
                colors:             ["#666","#666","#eee","#b9e3ee","#ebe94b","#46cafb","#eca48f","#decb3d","#8d1894"],
                backgroundColors:   ["#ddd","#ddd","#999","#379dc3","#36be0d","#001cc6","#da4324","#56125a","#ffffff"]
            }
        },
        computed: {
            x: function () {
                return 125*this.p.charAt(0)+"px";
            },
            y: function () {
                return 125*this.p.charAt(2)+"px";
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
        watch: {
            p: function (val) {
                animation.transition(this.$refs['stone'],{
                    styles: {
                        transform: 'translate('+this.x+',-'+this.y+')'
                    },
                    duration: 200,
                    timingFunction: 'ease-in',
                    delay: 0
                });
            },
            num: function (val) {
                if(val != 0) {
                    animation.transition(this.$refs['stone'], {
                        styles: {
                            color: this.colors[this.score],
                            backgroundColor: this.backgroundColor[this.score]
                        },
                        duration: 200,
                        timingFunction: 'ease',
                        delay: 0
                    });
                }else{
                    animation.transition(this.$refs['stone'], {
                        styles: {
                            color: '#fff',
                            backgroundColor: '#fff'
                        },
                        duration: 200,
                        timingFunction: 'ease',
                        delay: 0
                    });
                }
            }
        },
        mounted(){
            this.initState(this.p0);
        },
        methods: {
            move(_x, _y){
                this.p = _x + ',' + _y;
            },
            scoreChange(_num){
                this.num = _num;
            },
            initState(_p){
                _p = _p.split(',');
                let _x = _p[0] * 125 + 'px',
                    _y = _p[1] * 125 + 'px';
                this.num = this.num0;
                animation.transition(this.$refs['stone'],{
                    styles: {
                        transform: 'translate('+_x+',-'+_y+')'
                    },
                    duration: 10,
                    delay: 0
                },()=>{
                    this.visibility = 'visible';
                });
                this.p = this.p0;
            }
        }
    }
</script>