<template>
    <div class="u-slider">
        <template v-for="i in stones">
            <stone :ref="i.id" :id="i.id" :p0="i.p0" :num0="i.s"></stone>
        </template>
    </div>
</template>

<style scoped>
    .u-slider{

    }
</style>

<script>

    const modal = weex.requireModule('modal');
    import stone from './stone.vue';
    export default {
        components: {
            stone: stone
        },
        data(){
            return {
                stones:[],
                map: [
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', ''],
                    ['', '', '', '', '', '']
                ],
                sliderIndex: 1,
                actionLock: false
            }
        },
        mounted(){
            this.pushStones();
            console.log('stones',this.stones);
            console.log('map',this.map);
        },
        methods: {
            /**
             * 事件控制
             * */
            action(_action){
                if(!!this.actionLock) return;
                switch (_action){
                    case 'click':
                    case 'up':
                        modal.toast({message:'change',duration:0.1});
                        this.actionChange();
                        break;
                    case 'left':
                    case 'right':
                        this.actionSliderMove(_action);
                        break;
                    case 'down':
                        this.actionDown();
                        break;
                    default:
                        modal.toast({message:'unknown',duration:0.1});
                }
                this.actionLock = true;
                setTimeout(()=>{this.actionLock = false;},199);
            },
            /**
             * 新增三个单元块
             * */
            pushStones(){
                let _ps = [],_id;
                this.sliderIndex = Math.floor(Math.random()*4);
                for(let i=0;i<3;i++) {
                    _id = 's' + (Math.floor(Math.random() * 1000000) + Date.now());
                    _ps.push({
                        id: _id,
                        p0: this.sliderIndex + i + ',7',
                        s: Math.floor(Math.random() * 1.5) + 1
                    });
                    this.map[0][this.sliderIndex + i] = _id;
                }
                this.stones.push(..._ps);
            },
            /**
             * 滑块切换
             * */
            actionChange() {
                let _id1 = this.map[0][this.sliderIndex],
                    _id2 = this.map[0][this.sliderIndex + 1],
                    _id3 = this.map[0][this.sliderIndex + 2];

                this.sChange(_id1, 2);
                this.map[0][this.sliderIndex+2] = _id1;
                this.sChange(_id2, -1);
                this.map[0][this.sliderIndex] = _id2;
                this.sChange(_id3, -1);
                this.map[0][this.sliderIndex+1] = _id3;

            },
            /**
             * 滑块左右滚动
             * */
            actionSliderMove(_d){
                if(this.sliderIndex<=0 && _d=='left' || this.sliderIndex>=3 && _d=='right')return;
                modal.toast({message:_d,duration:0.1});
                let _id1 = this.map[0][this.sliderIndex],
                    _id2 = this.map[0][this.sliderIndex + 1],
                    _id3 = this.map[0][this.sliderIndex + 2],
                    _addend = _d=='left'? -1 : 1;

                this.sChange(_id1, _addend);
                this.map[0][this.sliderIndex+_addend] = _id1;
                this.sChange(_id2, _addend);
                this.map[0][this.sliderIndex+_addend+1] = _id2;
                this.sChange(_id3, _addend);
                this.map[0][this.sliderIndex+_addend+2] = _id3;
                this.sliderIndex += _addend;

            },
            /**
             * 单元块位置移动+权重加码
             * */
            sChange(_id,_p,_score){
                if(typeof _p == 'string' && _p.split(',')) {
                    this.sMove(_id, _p.split(',')[0], _p.split(',')[1]);
                }else if(typeof _p == 'number' && _p<=3 && _p>=-3){
                    var _tp = this.$refs[_id][0].p;
                    this.sMove(_id,  parseInt(_tp.split(',')[0])+_p , _tp.split(',')[1]);
                }
                _score && this.sUp(_id,_score);
            },
            /**
             * 单元块位置移动+权重加码
             * */
            actionDown(){
                var _id = this.stones[0].id;
                this.sChange(_id, '0,0');
            },

            /**
             * 单元块位置移动
             * */
            sMove(_id,_x,_y){
                this.$refs[_id][0].move(_x,_y);
            },
            /**
             * 权重加码
             * */
            sUp(_id,_score){
                this.$refs[_id][0].scoreChange(_score);
            }
        }
    }
</script>