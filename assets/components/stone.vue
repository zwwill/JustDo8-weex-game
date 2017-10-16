<template>
    <text ref="stone" class="u-stone" :style="{color:color,visibility:visibility,backgroundColor:backgroundColor0}" v-if="score!=0">{{score}}</text>
</template>

<style scoped>
    .u-stone{
        width: 126px;
        height: 125px;
        border-bottom-width: 10px;
        border-bottom-color: rgba(0,0,0,0.2);
        line-height: 125px;
        text-align: center;
        font-size: 80px;
        color: #666;
        background-color: #fff;
        position: absolute;
        left: 0;
        bottom: 0;
        transform: translate(0px,-875px);
        opacity: 0.8;
        /*visibility: hidden;*/
    }
</style>

<script>
    const animation = weex.requireModule('animation');
    const modal = weex.requireModule('modal');
    export default {
        props: ['id', 'p0', 'num0'],
        data(){
            return {
                p: '0,7',
                visibility: '',
                num: -1,
                colors:             ["#333","#666","#eee","#b9e3ee","#ebe94b","#46cafb","#eca48f","#decb3d","#8d1894"],
                backgroundColors:   ["#222","#ddd","#999","#379dc3","#36be0d","#001cc6","#da4324","#56125a","#ffffff"]
            }
        },
        computed: {
            color: function () {
                return this.colors[this.num];
            },
            score: function () {
                this.num<0 && (this.num = this.num0 || 1);
                return this.num<9&&this.num>0?this.num:0
            },
            backgroundColor0: function () {
                return this.backgroundColors[this.num];
            }
        },
        watch: {
            p: function (val) {
                var _x = 125*this.p.charAt(0)+"px",
                    _y = 125*this.p.charAt(2)+"px";

                animation.transition(this.$refs['stone'],{
                    styles: {
                        transform: 'translate('+_x +',-'+_y+')'
                    },
                    duration: 200,
                    timingFunction: 'ease-in',
                    delay: 0
                });
            },
            num: function (val) {
                if(val>0 && val<9) {
//                    animation.transition(this.$refs['stone'], {
//                        styles: {
//                            color: this.colors[this.score]
//                        },
//                        duration: 200,
//                        timingFunction: 'ease',
//                        delay: 0
//                    });
                }else{
//                    animation.transition(this.$refs['stone'], {
//                        styles: {
//                            color: '#fff'
//                        },
//                        duration: 200,
//                        timingFunction: 'ease',
//                        delay: 0
//                    },()=>{{this.$emit('stonePop',this.data.id)}});
//                    modal.toast({message:"dsf",duration:0.1})
//                    this.$parent.$emit('stonePop',123);
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