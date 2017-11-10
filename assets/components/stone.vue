<template>
    <text ref="stone" class="u-stone" :style="{color:color,backgroundColor:backgroundColor0}" v-if="show" >{{score}}</text>
</template>

<style scoped>
    .u-stone{
        width: 126px;
        height: 125px;
        border-bottom-width: 10px;
        border-bottom-color: rgba(0,0,0,0.2);
        /*border-width: 4px;*/
        /*border-color: rgba(0,0,0,0.2);*/
        line-height: 125px;
        text-align: center;
        font-size: 80px;
        color: #666;
        background-color: #fff;
        position: absolute;
        left: 0;
        bottom: 0;
        transform: translate(0px,-2000px);
        /*opacity: 0.8;*/
        /*visibility: hidden;*/
    }
</style>

<script>
    const animation = weex.requireModule('animation');
    export default {
        props: ['id', 'p0', 'num0'],
        data() {
            return {
                show: true,
                p: '0,8',
                visibility: '',
                num: -1,
                colors: ["#333", "#666", "#eee", "#b9e3ee", "#ebe94b", "#46cafb", "#eca48f", "#decb3d", "#8d1894"],
                backgroundColors: ["#222", "#ddd", "#999", "#379dc3", "#36be0d", "#001cc6", "#da4324", "#56125a", "#ffffff"]
            }
        },
        computed: {
            color: function () {
                return this.colors[this.num];
            },
            score: function () {
                this.num < 0 && (this.num = this.num0 || 1);
                return this.num < 9 && this.num > 0 ? this.num : 0
            },
            backgroundColor0: function () {
                return this.backgroundColors[this.num];
            }
        },
        watch: {
            p: function (val) {
                var _x = 125 * val.charAt(0) + "px",
                    _y = 125 * val.charAt(2) + "px";
                animation.transition(this.$refs['stone'], {
                    styles: {
                        transform: 'translate(' + _x + ',-' + _y + ')'
                    },
                    duration: 200,
                    timingFunction: 'ease-in',
                    delay: 0
                });
            }
        },
        mounted() {
            this.initState(this.p0);
        },
        methods: {
            /**
             * 移动数字块
             * */
            move(_x, _y) {
                this.p = _x + ',' + _y;
//                this.moveP(_x,_y);
            },
            /**
             * 更新数字块的分值，即显示数字
             * */
            scoreChange(_num) {
                if (_num > 0) {
                    this.num = _num;
                } else {

                    animation.transition(this.$refs['stone'], {
                        styles: {
                            transform: 'translate(' + 125 * 5 + ',-' + 125 * 9 + ') scale(0)'
                        },
                        duration: 700,
                        timingFunction: 'ease-in',
                        delay: 0
                    }, () => {
                        this.show = false;
                        this.$parent.scorePlus(Math.pow(4, parseInt(this.num)));
                        this.num = 0;
                        this.$destroy();
                    });
                }
            },
            /**
             * 初始化数字块的位置
             * */
            initState(_p) {
                _p = _p.split(',');
                let _x = _p[0] * 125 + 'px',
                    _y = _p[1] * 125 + 'px';
                this.num = this.num0;
                animation.transition(this.$refs['stone'], {
                    styles: {
                        transform: 'translate(' + _x + ',-' + _y + ')'
                    },
                    duration: 5,
                    delay: 0
                },()=>{
                    this.p = this.p0;
                });
//                this.moveP(this.p0.charAt(1),this.p0.charAt(2))
            },
            moveP(_x0,_y0){
                var _x = 125 * _x0 + "px",
                    _y = 125 * _y0 + "px";
                animation.transition(this.$refs['stone'], {
                    styles: {
                        transform: 'translate(' + _x + ',-' + _y + ')'
                    },
                    duration: 200,
                    timingFunction: 'ease-in',
                    delay: 0
                });
            }
        }
    }
</script>